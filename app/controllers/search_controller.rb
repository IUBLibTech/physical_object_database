class SearchController < ApplicationController
  def search_results
    
    @search = true
    term = params[:identifier]
    @physical_objects = PhysicalObject.search_by_barcode_title_call_number(term)
    flash[:notice] = @physical_objects.size == 0 ? "No results for barcode #{term}" : "Search Results for <i>#{term}</i>".html_safe
    if @physical_objects.nil?
      redirect_to(action: 'index')
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
    tm.as_technical_metadatum = stm
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

end
