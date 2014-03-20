class SearchController < ApplicationController
  
  def index
    
  end
  
  def search_results
    term = params[:identifier].strip.gsub(/[*]/, '%')
    @physical_objects = PhysicalObject.search_id(term)
    printf("\n\nHmm %s\n\n", @physical_objects)
    flash[:notice] = @physical_objects[0] == nil ? "No results for #{term}" : "Search Results for #{term}"
    render('physical_objects/index')
  end

  def search_multi_results
    
  end
  

end
