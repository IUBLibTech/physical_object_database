class SearchController < ApplicationController
  def search_results
    term = params[:identifier]
    @physical_object = PhysicalObject.search_by_barcode(term).first
    flash[:notice] = @physical_object.nil? ? "No results for barcode #{term}" : "Search Results for barcode <i>#{term}</i>".html_safe
    if @physical_object.nil?
      redirect_to(action: 'index')
    else
      redirect_to(controller: 'physical_objects', action: 'show', id: @physical_object.id)
    end
  end

  def index
    @physical_object = PhysicalObject.new
    @physical_object.format = @physical_object.formats["Open Reel Tape"]
    @tm = @physical_object.create_tm(@physical_object.format)
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
    flash[:notice] = "Your search returns these results"
    render('physical_objects/index')
  end
  

  private
  def physical_object_sql(params)
    
  end

end
