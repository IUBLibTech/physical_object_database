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
  end  

  def advanced_search
    @search_mode = true
    po = PhysicalObject.new
    po.attributes.keys.each { |att| po[att] = nil }
    po.assign_attributes(clean_arrays(physical_object_params))
    if params[:tm] && (tm = po.ensure_tm)
      tm.attributes.keys.each { |att| tm[att] = nil unless att == "subtype" }
      tm.assign_attributes(clean_arrays(tm_params))
    end
    omit_picklisted = (params[:omit_picklisted] == 'true')
    @physical_objects = po.physical_object_query(omit_picklisted, SEARCH_RESULTS_LIMIT)
    @results_count = @physical_objects.size
    flash.now[:notice] = "Your search returns these results"
    flash.now[:warning] = "Your search results have been limited to #{SEARCH_RESULTS_LIMIT}." if @results_count >= SEARCH_RESULTS_LIMIT && SEARCH_RESULTS_LIMIT > 0
    render('physical_objects/index')
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

end
