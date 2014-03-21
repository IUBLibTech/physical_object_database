class PhysicalObjectsController < ApplicationController
  require 'csv'
  
  helper_method :render_tm_partial

  def new
    # we instantiate an new object here because rails will pick up any default values assigned
    # by the database and the form will be prepopulated with those values
    # we can also pass a hash to PhysicalObject.new({iu_barcode => 123436}) to assign defaults programmatically
    @physical_object = PhysicalObject.new
    @formats = @physical_object.formats
    puts formats
    @edit_mode = true
    @action = "create"
  end

  def create
    @physical_object = PhysicalObject.new(physical_object_params)
    @physical_object.init_tm
    if @physical_object.save
      flash[:notice] = "#{@physical_object.shelf_number} was successfully created"
      redirect_to(:action => 'index')
    else
      @edit_mode = true
      render('new')
    end
  end

  def index
    @physical_objects = PhysicalObject.all
  end

  def show
    @edit_mode = false;
    @physical_object = PhysicalObject.find(params[:id])
    @tm = @physical_object.technical_metadatum.specialize
  end

  
  def edit
    @action = 'update'
    @edit_mode = true
    @physical_object = PhysicalObject.find(params[:id])
    @tm = @physical_object.technical_metadatum.specialize
    if @physical_object.technical_metadatum.nil?
      tm = @physical_object.init_tm
      tm.physical_object = @physical_object
      tm.save
    end
  end

  def update
    @physical_object = PhysicalObject.find(params[:id])
    if @physical_object.update_attributes(physical_object_params)
      @tm = @physical_object.technical_metadatum.specialize
      @tm.update_attributes(@tm.update_form_params(params['physical_object']))
      puts(params['physical_object'].to_yaml)
      flash[:notice] = "Physical Object successfully updated."
      redirect_to(:action => 'show', :id => @physical_object.id)
    else
      @edit_mode = true
      render("show")
    end
  end

  
  def delete
    @physical_object = PhysicalObject.find(params[:id])
  end

  def destroy
    physical_object = PhysicalObject.find(params[:id]).destroy
    flash[:notice] = "#{physical_object.shelf_number} was successfully deleted."
    redirect_to(:action => 'index')
  end
  
  
  
  def split_show
    @physical_object = PhysicalObject.find(params[:id]);
    @count = 0;
    
  end
  
  def split_update
    template = PhysicalObject.find(params[:id])
    (params[:count].to_i - 1).times do |i|
      po = PhysicalObject.new({:iu_barcode => template.iu_barcode, :shelf_number => template.shelf_number, :call_number => template.call_number})
      po.save
    end
    flash[:notice] = "#{template.shelf_number} was successfully split into #{params[:count]} records."
    redirect_to({:action => 'index'})
  end
  
  def upload_show
    @physical_object = PhysicalObject.new
  end
  
  def upload_update
    path = params[:physical_object][:csv_file].path
    csv = CSV.parse(File.read(path), :headers => true)
    record_count = 0;
    csv.each do |row|
      if PhysicalObject.where(:shelf_number => row[1]).blank?
        po = PhysicalObject.new(:shelf_number => row[1])
        po.save
        record_count = record_count + 1;
      else
        printf("%s already exists in the database", row[1])
      end
    end
    flash[:notice] = "#{record_count} new records were added to the POD."
    redirect_to({:action => 'index'})
  end

  def render_tm_partial(po)
    if po.format == "Open Reel Tape"
      "technical_metadatum/show_open_reel_tape_tm"
    elsif po.format == "Cassette Tape"
        "technical_metadatum/show_cassette_tape_tm"
    else
      flash[:notice] = "Unknown format: #{po.format}"
    end
  end
  
  private
    def physical_object_params
      # same as using params[:physical_object] except that it
      # - allows listed attributes to ne mass-assigned
      # we could also do params.require(:some_field).permit*...
      # if certain fields were required for the object instantiation.
      params.require(:physical_object).permit(:memnon_barcode, 
        :iu_barcode, :shelf_number, :call_number, :title, :format, :nit,
        :collection_id, :primary_location, :secondary_location, :composer_performer,
        :sequence, :open_reel_tm, :bin_id, :unit, )
    end
end
