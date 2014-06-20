class PhysicalObjectsController < ApplicationController
  before_action :set_physical_object, only: [:show, :edit, :update, :destroy, :split_show, :unbin, :unbox, :unpick]  
  helper :all

  def download_spreadsheet_example
    send_file("#{Rails.root}/public/CSV_Import.xlsx", filename: "CSV_Import.xlsx")
  end

  def new
    # we instantiate an new object here because rails will pick up any default values assigned
    # by the database and the form will be prepopulated with those values
    # we can also pass a hash to PhysicalObject.new({iucat_barcode => 123436}) to assign defaults programmatically
    @physical_object = PhysicalObject.new
    #default format for now
    format = PhysicalObject.formats["Open Reel Audio Tape"]
    @physical_object.format = format
    @tm = @physical_object.create_tm(format)
    @digital_files = []
    @formats = PhysicalObject.formats
    @edit_mode = true
    @action = "create"
    @submit_text = "Create Physical Object"
    @display_assigned = false
  end

  def create
    @physical_object = PhysicalObject.new(physical_object_params)
    @tm = @physical_object.create_tm(@physical_object.format)
    @tm.physical_object = @physical_object
    if @physical_object.save and @tm.update_attributes(tm_params)
      flash[:notice] = "Physical Object was successfully created.".html_safe
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
    @display_assigned = true
  end

  def edit
    @action = 'update'
    @edit_mode = true
    @display_assigned = true
  end

  def update
    puts params.to_yaml
    PhysicalObject.transaction do
      old_format = @physical_object.format
      if ! @physical_object.update_attributes(physical_object_params)
        @edit_mode = true
        render action: :edit
      else
        # format change requires deleting the old technical_metadatum and creating a new one
        if old_format != params[:physical_object][:format]
          @tm.destroy
          @tm = @physical_object.create_tm(@physical_object.format)
          @tm.physical_object = @physical_object
        end
        @tm.update_attributes(tm_params)
        @tm.save
        flash[:notice] = "Physical Object successfully updated".html_safe
        redirect_to(action: 'index')
      end
    end
  end

  def destroy
    @tm.destroy unless @tm.nil?
    @physical_object.destroy
    flash[:notice] = "Physical Object was successfully deleted.".html_safe
    redirect_to physical_objects_path
  end
  
  def split_show
    @count = 0;
    @display_assigned = true
  end
  
  def split_update
    if  params[:count].to_i > 1
      container = Container.new
      container.save
      template = PhysicalObject.find(params[:id])
      template.group_position = 1
      template.container_id = container.id
      template.save

      (params[:count].to_i - 1).times do |i|
        po = template.dup
        po.mdpi_barcode = 0
        po.group_position = i + 2
        po.container_id = container.id
        tm = template.technical_metadatum.as_technical_metadatum.dup
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
      flash[:notice] = "Please specify a file to upload"
      redirect_to(action: 'upload_show')
    else
      @pl = nil
      unless params[:pl][:name].length == 0
        @pl = Picklist.new(name: params[:pl][:name], description: params[:pl][:description])
        @pl.save
      end
      path = params[:physical_object][:csv_file].path
      filename = params[:physical_object][:csv_file].original_filename
      added = PhysicalObjectsHelper.parse_csv(path, @pl, filename)
      flash[:notice] = "#{added['succeeded'].size} records were successfully imported.".html_safe
      if added['failed'].size > 0
        @failed = added['failed']
      end
    end
  end
    
  def unbin
    @bin = @physical_object.bin
    @physical_object.bin = nil
    if @bin.nil?
       flash[:notice] = "<strong>Physical Object was not associated to a Bin.</strong>".html_safe
    elsif @physical_object.save
      flash[:notice] = "<em>Physical Object was successfully removed from bin.</em>".html_safe
    else
      flash[:notice] = "<strong>Physical Object was NOT removed from bin.</strong>".html_safe
    end
    unless @bin.nil?
      redirect_to @bin
    else
      redirect_to @physical_object
    end
  end

  def unbox
    @box = @physical_object.box
    @physical_object.box = nil
    if @box.nil?
       flash[:notice] = "<strong>Physical Object was not associated to a Box.</strong>".html_safe
    elsif @physical_object.save
      flash[:notice] = "<em>Physical Object was successfully removed from box.</em>".html_safe
    else
      flash[:notice] = "<strong>Physical Object was NOT removed from box.</strong>".html_safe
    end
    unless @box.nil?
      redirect_to @box
    else
      redirect_to @physical_object
    end
  end

  def unpick
    @picklist = @physical_object.picklist
    @physical_object.picklist = nil
    if @picklist.nil?
      flash[:notice] = "<strong>Physical Object was not associated to a Picklist.</strong>".html_safe
    elsif @physical_object.save
      flash[:notice] = "<em>Physical Object was successfully removed from Picklist.</em>".html_safe
    else
      flash[:notice] = "<strong>Failure; Physical Object was NOT removed from Picklist.</strong>".html_safe
    end
    unless @picklist.nil?
      redirect_to @picklist
    else
      redirect_to @physical_object
    end
  end
  
  private
    def set_physical_object
      @physical_object = PhysicalObject.find(params[:id])
      @digital_files = @physical_object.digital_files
      @tm = @physical_object.technical_metadatum
      @tm = @physical_object.technical_metadatum.specialize unless @tm.nil?
      @bin = @physical_object.bin
      @box = @physical_object.box
    end

    
end
