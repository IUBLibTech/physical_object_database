class CollectionOwnerController < ApplicationController
  before_action :check_authorization
  SEARCH_RESULTS_LIMIT = 500

  def index
    @physical_objects = PhysicalObject.collection_owner_filter(@unit.id)
    if request.format.html?
      @physical_objects = @physical_objects.paginate(page: params[:page])
    end
  end

  def show
    @physical_object = PhysicalObject.collection_owner_filter(@unit.id).where(id: params[:id]).first
    if @physical_object.nil?
      flash[:warning] = "No Physical object found belonging to #{@unit.name} with ID: #{params[:id]}"
      redirect_to collection_owner_index_path
    end
  end

  def search
    @edit_mode = true
    @search_mode = true
    @physical_object = PhysicalObject.new
    @physical_object.attributes.keys.each { |att| @physical_object[att] = nil }
    @physical_object.unit = @unit
  end

  def search_results
    @full_results = PhysicalObject.physical_object_query(search_params).collection_owner_filter(@unit.id)
    @physical_objects = @full_results.limit(SEARCH_RESULTS_LIMIT)
    @results_count = @physical_objects.size
    flash.now[:notice] = "Your search returns these results"
    flash.now[:warning] = "Your search returned #{@full_results.size} results, but display has been limited to the first #{SEARCH_RESULTS_LIMIT}." if @results_count >= SEARCH_RESULTS_LIMIT && SEARCH_RESULTS_LIMIT > 0
    respond_to do |format|
      format.html { render :search_results }
      format.xls do
        @physical_objects = @full_results
        render :index
      end
    end

  end

  private
    def check_authorization
      authorize :collection_owner
      if @pundit_user.nil? || @pundit_user.unit.nil?
        flash[:warning] = 'You must have an associated Unit to use collection owner services.'
        redirect_to welcome_index_path
      end
      @unit = @pundit_user.unit
    end

    #forms summit dummy initial "" in arrays from multi-selects
    def clean_arrays(h)
      h.each do |k,v|
        if v.class == Array && v.first == ""
          h[k] = ((v.size > 1) ? v[1,v.size - 1] : nil)
        end
      end
    end

    def po_search_params
      clean_arrays(physical_object_params)
    end

    def search_params
      search_parameters = {}
      search_parameters[:physical_object] = po_search_params if params[:physical_object]
      search_parameters
    end
 
end
