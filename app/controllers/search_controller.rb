class SearchController < ApplicationController
  before_action :authorize_search
  SEARCH_RESULTS_LIMIT = 500
  def search_results
	@search = true
    term = params[:identifier].to_s
    limit = 1000
    if term.blank?
      @physical_objects = PhysicalObject.none
      @bins = Bin.none
      @boxes = Box.none
      flash.now[:warning] = "No search term was entered."
    else
      @physical_objects = PhysicalObject.search_by_barcode_title_call_number(term).limit(limit)
      @bins = Bin.where("mdpi_barcode LIKE ? OR identifier LIKE ?", "%#{term}%", "%#{term}%").limit(limit)
      @boxes = Box.where("mdpi_barcode LIKE ?", "%#{term}%").limit(limit)
      flash.now[:notice] = "Search results for term: <em>#{term}</em>".html_safe
      flash.now[:warning] = "Search results limit of #{limit} reached.  Some search results may not be listed." if @physical_objects.size >= limit || @bins.size >= limit || @boxes.size >= limit
    end
  end

  def index
    @physical_object = PhysicalObject.new
    @tm = @physical_object.ensure_tm
    @dp = @physical_object.ensure_digiprov
    @display_assigned = false
    @edit_mode = true
    @search_mode = true
    @submit_text = "Search"
    @controller = 'search'
    @action = "advanced_search"
    @physical_object.attributes.keys.each { |att| @physical_object[att] = nil }
    @note = Note.new
    @note.attributes.keys.each { |att| @note[att] = nil }
    @condition_status = ConditionStatus.new
    @condition_status.attributes.keys.each { |att| @condition_status[att] = nil }
    @workflow_status = WorkflowStatus.new
    @workflow_status.attributes.keys.each { |att| @workflow_status[att] = nil }
  end  

  def advanced_search
    @search_mode = true
    @search_params = search_params
    @full_results = PhysicalObject.physical_object_query(search_params).eager_load(:box, :bin, :box_bin, :box_batch, :bin_batch, :unit, :notes, :condition_statuses, :group_key, :technical_metadatum)
    if params[:workflow_status]
      ws_params = workflow_status_params
      @ws_params = workflow_status_params
      if ws_params[:workflow_status_template_id] && ws_params[:workflow_status_template_id].any? && !ws_params[:created_at].blank? && !ws_params[:updated_at].blank?
        @full_results = @full_results.workflow_status_search(ws_params[:workflow_status_template_id], ws_params[:created_at], ws_params[:updated_at])
      end
    end
#FIXME: add 2 note scopes, condition status scope
#FIXME: figure out why tm is not included
    @physical_objects = @full_results.limit(SEARCH_RESULTS_LIMIT)
    @results_count = @physical_objects.size
    flash.now[:notice] = "Your search returns these results"
    flash.now[:warning] = "Your search returned #{@full_results.size} results, but display has been limited to the first #{SEARCH_RESULTS_LIMIT}." if @results_count >= SEARCH_RESULTS_LIMIT && SEARCH_RESULTS_LIMIT > 0
    respond_to do |format|
      format.html { render :advanced_search_results }
      format.xls do
        @block_metadata = format_param.blank?
        @physical_objects = @full_results
        render 'show' 
      end
      format.report do
        PodReportJob.perform_later(search_params, ws_params)
        redirect_to pod_reports_path
      end
    end
  end

  private
    def authorize_search
      authorize :search
    end

    #forms summit dummy initial "" in arrays from multi-selects
    def clean_arrays(h)
      h.each do |k,v|
        if v.class == Array && v.first == ""
          h[k] = ((v.size > 1) ? v[1,v.size - 1] : nil)
        end
      end
    end

    # association parameters for physical object, passed separately as physical_object will not hold array of values in an _id field
    def association_params
      clean_arrays(params.require(:physical_object).permit(unit_id: [], picklist_id: [], spreadsheet_id: [], box_id: [], bin_id: []))
    end

    def po_search_params
      clean_arrays(physical_object_params).merge(association_params)
    end

    def tm_search_params
      clean_arrays(tm_params)
    end

    def condition_status_params
      clean_arrays(params.require(:condition_status).permit(:notes, :active, :user, condition_status_template_id: []))
    end

    def workflow_status_params
      clean_arrays(params.require(:workflow_status).permit(:created_at, :updated_at, workflow_status_template_id: []))
    end

    def note_params
      clean_arrays(params.require(:note).permit(:body, :user, :export))
    end

    def omit_picklisted_param
      params[:omit_picklisted].to_s == 'true'
    end

    def format_param
      params[:physical_object] ? params[:physical_object][:format] : nil
    end

    def search_params
      search_parameters = {}
      search_parameters[:physical_object] = po_search_params if params[:physical_object]
      if omit_picklisted_param
        search_parameters[:physical_object] ||= {}
        search_parameters[:physical_object][:picklist_id] = [0, nil]
      end
      search_parameters[:technical_metadatum] = tm_search_params if params[:tm] && format_param
      search_parameters[:condition_status] = condition_status_params if params[:condition_status]
      search_parameters[:note] = note_params if params[:note]
      search_parameters
    end

end
