class PodReportJob < ActiveJob::Base
  queue_as :default
  attr_reader :search_params, :ws_params

  def perform(search_params, ws_params)
    @search_params = search_params
    @ws_params = ws_params
    pr = PodReport.new(filename: filename, status: "WAITING TO START")
    pr.save!

    begin
      write_report(pr)
    rescue => error
      logger.error "Error casued by: #{error.message}"
      logger.error error.backtrace.join("\n")
      pr.update_attributes!(status: 'ERROR')
    end
  end

  private
    def filename
      @filename ||= Time.now.to_formatted_s.split(' ')[0,2].join('_').gsub(':', '') + '.xls'
    end

    def logger
      @logger = Logger.new(Rails.root.join('log', 'pod_report_job.log'))
    end

    def write_report(pr)
      logger.info "Initializing report file: #{pr.full_path}"
      logger.info "Search params: #{@search_params.inspect}"
      logger.info "Workflow Status params: #{@ws_params.inspect}"
      File.write(pr.full_path, 
                 ApplicationController.new.render_to_string(
                   template: 'search/report_open.xls',
                   format: 'xls',
                   locals: { :@block_metadata => true } )
                )
      logger.info "Opening report for writing"
      f = File.open(pr.full_path, 'a')

      total = physical_objects.count
      percentage = 0
      physical_objects.find_each.with_index do |po, index|
          f.write(ApplicationController.new.render_to_string(
                  template: 'search/_search_physical_object.xls',
                  format: 'xls',
                  locals: { po: po, :@metadata_headers => [] } )
                  )
                
        updated_percentage = ((index + 1).to_f / total.to_f * 100.0).round
        if updated_percentage > percentage
          pr.update_attributes!(status: "#{updated_percentage}% (ETA: #{eta(pr.created_at, updated_percentage)})")
          percentage = updated_percentage
          logger.info "Report updated to #{updated_percentage}"
        end
      end
      logger.info "Report main loop completed."

      
      f.write(ApplicationController.new.render_to_string(
                template: 'search/report_close.xls',
                format: 'xls' )
              )

      f.close
      logger.info "Report file closed."

      pr.update_attributes!(status: 'Available')
      logger.info "Report status updated completed."
    end

    def eta(start_time, percentage)
      time_passed = (Time.now - start_time)
      percent_remaining = (100.0 - percentage)
      time_remaining = percent_remaining * time_passed / percentage
      Time.now + time_remaining
    end

    def physical_objects
      @full_results = PhysicalObject.physical_object_query(search_params).eager_load(:box, :bin, :box_bin, :box_batch, :bin_batch, :unit, :notes, :condition_statuses, :group_key, :technical_metadatum)
      if ws_params[:workflow_status_template_id] && ws_params[:workflow_status_template_id].any? && !ws_params[:created_at].blank? && !ws_params[:updated_at].blank?
        @full_results = @full_results.workflow_status_search(ws_params[:workflow_status_template_id], ws_params[:created_at], ws_params[:updated_at])
      end
      @full_results
    end
end
