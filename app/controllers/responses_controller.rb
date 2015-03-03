# Does not inherit from ApplicationController to avoid requiring sign-in here
class ResponsesController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include BasicAuthenticationHelper
  before_action :authenticate

  before_action :set_physical_object, only: [:metadata, :pull_state]

  def metadata
    @status = 200
    render template: 'responses/metadata.xml.builder', layout: false, status: @status
  end

  # message: handled by messages controller
  # push_status is used for notifying POD of digital status changes from Brian's
  # QC script. Expected format of request: 
  #<app root>/responses/push_status?json=<json status object>&qc_user=<Settings.qc_user>&qc_pass=<Settings.qc_pass>
  def push_status
    puts "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    status = 200
    begin
      if params[:json]
        ds = DigitalStatus.new.from_json(params[:json])
        if ds.valid_physical_object?
          @message = "Status updated"
          ds.save
        else
          @message = "Unknown physical object from json: #{params[:json]}"
          status = 400
        end
      else
        @message = "Missing json param..."
        status = 400
      end
    rescue ParseError => e
      status = 400
      puts e.message  
      puts e.backtrace.inspect 
      @message = "Parsing JSON string failed:\n#{e.message}\n#{e.backtrace.inspect}"
    rescue Exception => e
      status = 501
      puts e.message
      puts e.backtrace.inspect
    end
    render template: 'responses/push_status_response.xml.builder', layout: false, status: status
  end

  # this action is for Brian's automated QC process to to query what the last decision the user made regard a fork
  # in the qc workflow. Response format is expect to be:
  # <app root>/responses/pull_stat/barcode?qc_user=<Settings.qc_user>&qc_pass=<Settings.qc_pass>
  def pull_state
    puts "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    if @physical_object
      @ds = @physical_object.digital_statuses.order("updated_at DESC").last
      unless @ds.nil?
        @status = 200
        @message = @ds.decided
      else
        @status = 400
        @message = "Physical object #{@physical_object.mdpi_barcode} has 0 Digital Statuses..."
      end
    else
      @status = 400
      @message = "Unknown physical object: #{params[:barcode]}"
    end
    render template: 'responses/push_status_response.xml.builder', layout: false, status: status
  end


  private
    def set_physical_object
      @physical_object = PhysicalObject.find_by(mdpi_barcode: response_params[:barcode]) unless response_params[:barcode].to_i.zero?
    end

    def response_params
      params.permit(:barcode)
    end
end
