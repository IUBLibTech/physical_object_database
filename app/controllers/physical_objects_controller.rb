class PhysicalObjectsController < ApplicationController
  
  helper :all

  def new
    # we instantiate an new object here because rails will pick up any default values assigned
    # by the database and the form will be prepopulated with those values
    # we can also pass a hash to PhysicalObject.new({iucat_barcode => 123436}) to assign defaults programmatically
    @physical_object = PhysicalObject.new
    #default format for now
    format = @physical_object.formats["Open Reel Tape"]
    @physical_object.format = format
    @tm = @physical_object.create_tm(format)
    @digital_files = []
    @formats = @physical_object.formats
    @edit_mode = true
    @action = "create"
    @submit_text = "Create Physical Object"
    @display_assigned = false
  end

  def create
    @physical_object = PhysicalObject.new(physical_object_params)
    if @physical_object.format.length > 0 && @physical_object.save
      tm = @physical_object.create_tm(@physical_object.format)
      tm.physical_object = @physical_object
      tm.update_form_params(params)
      tm.save
      flash[:notice] = "<i>#{@physical_object.title}</i> was successfully created".html_safe
      redirect_to(:action => 'index')
    else
      if @physical_object.format.length == 0
        flash[:notice] = "<b class='warning'>You must specify a format</b>"
      else
        flash[:notice] = "<b class=warning>Unable to save physical object</b>"
      end
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
    @digital_files = @physical_object.digital_files
    @tm = @physical_object.technical_metadatum.specialize
  end

  def edit
    @action = 'update'
    @edit_mode = true
    @physical_object = PhysicalObject.find(params[:id])
    @digital_files = @physical_object.digital_files
    @display_assigned = true
    if @physical_object.technical_metadatum.nil?
      flash[:notice] = "A physical object was created without specifying its technical metadatum..."
      redirect_to(action: 'show', id: @physical_object.id)
    else
      @tm = @physical_object.technical_metadatum.specialize  
    end
  end

  def update
    @physical_object = PhysicalObject.find(params[:id])
    old_format = @physical_object.format
    if ! @physical_object.update_attributes(physical_object_params)
      flash[:notice] = "Unable to save #{@physical_object.title}"
      @edit_mode = true
      #redirect_to(action: :edit, id: @physical_object.id)
      render action: :edit
    else
      # format change requires deleting the old technical_metadatum and creating a new one
      if old_format != params[:physical_object][:format]
        @physical_object.technical_metadatum.specialize.destroy
        tm = @physical_object.create_tm(@physical_object.format)
        tm.physical_object = @physical_object
        tm.update_form_params(params)
        tm.save
      else
        puts(params.to_yaml)
        tm = @physical_object.technical_metadatum.specialize
        tm.update_form_params(params)
        puts(tm.to_yaml)
        tm.save
      end
      flash[:notice] = "<i>#{@physical_object.title}</i> successfully updated".html_safe
      redirect_to(action: 'index')
    end
  end

  def destroy
    po = PhysicalObject.find(params[:id])
    if ! po.technical_metadatum.nil?
      po.technical_metadatum.specialize.destroy
    end
    po.destroy
    flash[:notice] = "<i>#{po.title}</i> was successfully deleted.".html_safe
    redirect_to physical_objects_path
  end
  
  def split_show
    @physical_object = PhysicalObject.find(params[:id]);
    @tm = @physical_object.technical_metadatum.specialize
    @digital_files = @physical_object.digital_files
    @count = 0;
    @display_assigned = true
  end
  
  def split_update
    if  params[:count].to_i > 1
      container = Container.new
      container.save
      template = PhysicalObject.find(params[:id])
      template.carrier_stream_index = 1
      template.container_id = container.id
      template.save

      (params[:count].to_i - 1).times do |i|
        po = template.dup
        po.carrier_stream_index = i + 2
        po.container_id = container.id
        tm = template.technical_metadatum.specialize.dup
        tm.physical_object = po
        tm.save
        po.save
      end
      flash[:notice] = "<i>#{template.title}</i> was successfully split into #{params[:count]} records.".html_safe
    end
    redirect_to({:action => 'index'})
  end
  
  def upload_show
    @physical_object = PhysicalObject.new
  end
  
  def upload_update
    if params[:physical_object].nil?
      redirect_to(action: 'upload_show')
      flash[:notice] = "Please specify a file to upload"
    else
      path = params[:physical_object][:csv_file].path
      added = PhysicalObjectsHelper.parse_csv(path)
      flash[:notice] = "#{added} records were imported."
      redirect_to({:action => 'index'})
    end
  end

  def get_tm_form
    f = params[:format]
    id = params[:id]
    @edit_mode = true
    @physical_object = params[:id] == '0' ? PhysicalObject.new : PhysicalObject.find(params[:id])
    if ! @physical_object.technical_metadatum.nil?
      @tm = @physical_object.technical_metadatum.as_technical_metadatum
    else
      tm = TechnicalMetadatum.new
      @tm = @physical_object.create_tm(f)
      @physical_object.technical_metadatum = tm
      tm.as_technical_metadatum = @tm
    end
    
    if f == "Open Reel Tape"
      render(partial: 'technical_metadatum/show_open_reel_tape_tm')
    elsif f == "Cassette Tape"
      render(partial: 'technical_metadatum/show_cassette_tape_tm')
    elsif f == "LP"
      render(partial: 'technical_metadatum/show_lp_tm')
    elsif f == "Compact Disc"
      render(partial: 'technical_metadatum/show_compact_disc_tm')
    end
  end
  
  private
    def physical_object_params
      # same as using params[:physical_object] except that it
      # allows listed attributes to be mass-assigned
      # we could also do params.require(:some_field).permit*...
      # if certain fields were required for the object instantiation.
      params.require(:physical_object).permit(:title, :title_control_number, 
        :unit, :home_location, :call_number, :shelf_location, :iucat_barcode, :format, 
        :carrier_stream_index, :collection_identifier, :mdpi_barcode, :format_duration,
        :content_duration, :has_media, :open_reel_tm, :bin_id, :unit,
	:current_workflow_status, condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :_destroy])
    end
end
