class SearchController < ApplicationController
  before_action :authorize_search
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
      @bins = Bin.where("mdpi_barcode LIKE ?", "%#{term}%").limit(limit)
      @boxes = Box.where("mdpi_barcode LIKE ?", "%#{term}%").limit(limit)
      flash.now[:notice] = "Search results for term: <em>#{term}</em>".html_safe
      flash.now[:warning] = "Search results limit of #{limit} reached.  Some search results may not be listed." if @physical_objects.size >= limit || @bins.size >= limit || @boxes.size >= limit
    end
  end

  def index
    @physical_object = PhysicalObject.new
    @physical_object.format = PhysicalObject.formats["CD-R"]
    @tm = @physical_object.create_tm(@physical_object.format)
    @dp = @physical_object.ensure_digiprov
    @display_assigned = true
    @edit_mode = true
    @submit_text = "Search"
    @controller = 'search'
    @action = "advanced_search"
  end  

  def advanced_search
    pop = params[:physical_object]
    tmp = params[:tm]

    po = PhysicalObject.new
    pop.each do |name, value|
      if !value.nil? and value.to_s.length > 0
        po[name] = value
      end 
    end

    tm = TechnicalMetadatum.new
    po.technical_metadatum = tm

    stm = po.create_tm(po.format)
    tm.specific = stm
    tmp.each do |name, value|
      if !value.nil? and value.length > 0
        stm[name] = value
      end
    end
    @physical_objects = PhysicalObject.advanced_search(po)
    #FIXME: employ pagination?
    flash[:notice] = "Your search returns these results"
    render('physical_objects/index')
  end

  private
    def authorize_search
      authorize :search
    end

end
