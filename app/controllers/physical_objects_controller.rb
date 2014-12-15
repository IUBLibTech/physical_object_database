class PhysicalObjectsController < ApplicationController
  before_action :set_physical_object, only: [:show, :edit, :update, :destroy, :split_show, :split_update, :unbin, :unbox, :unpick, :ungroup]  
  before_action :set_picklists, only: [:edit]
  helper :all

  def download_spreadsheet_example
    send_file("#{Rails.root}/public/CSV_Import.xlsx", filename: "CSV_Import.xlsx")
  end

  def new
    # we instantiate an new object here because rails will pick up any default values assigned
    # by the database and the form will be prepopulated with those values
    # we can also pass a hash to PhysicalObject.new({iucat_barcode => "123436"}) to assign defaults programmatically
    @physical_object = PhysicalObject.new
    #default format for now
    format = PhysicalObject.formats["Open Reel Audio Tape"]
    @physical_object.format = format
    @tm = @physical_object.ensure_tm
    @digital_files = []
    @formats = PhysicalObject.formats
    @edit_mode = true
    @action = "create"
    @submit_text = "Create Physical Object"
    @display_assigned = false

    if !params[:group_key_id].nil?
      @group_key = GroupKey.find(params[:group_key_id])
      @physical_object.group_key = @group_key
      @physical_object.group_position = @group_key.physical_objects_count + 1
    end
  end

  def create
    # catch whether this was from a "create multiple physical objects" link
    if params[:repeat] == "true"
      @repeat = true
    end
    @physical_object = PhysicalObject.new(physical_object_params)
    @tm = @physical_object.ensure_tm
    saved = @physical_object.save and @tm.update_attributes(tm_params)
    if saved
      flash[:notice] = "Physical Object was successfully created.".html_safe
    end
    if @repeat != true and saved
      redirect_to(:action => 'index')
    else
      @edit_mode = true
      if @repeat and saved
        @physical_object = PhysicalObject.new(physical_object_params)
        @tm = @physical_object.ensure_tm
        @tm.assign_attributes(tm_params)
      end
      render('new')
    end
  end

  def index
    @physical_objects = PhysicalObject.all
    if request.format.html?
      @physical_objects = @physical_objects.paginate(page: params[:page])
    end
  end

  def show
    @action = "show"
    @edit_mode = false;
    @display_assigned = true
  end

  def edit
    @action = 'update'
    @edit_mode = true
    @display_assigned = true
  end

  def update
    #puts params.to_yaml
    PhysicalObject.transaction do
      if ! @physical_object.update_attributes(physical_object_params)
        @edit_mode = true
        render action: :edit
      else
        # format change requires deleting the old technical_metadatum and creating a new one
        @tm = @physical_object.ensure_tm
        #FIXME: check for update success on tm?
        if @tm.update_attributes(tm_params)
          flash[:notice] = "Physical Object successfully updated".html_safe
          redirect_to(action: 'index')
        else
          @edit_mode = true
          render action: :edit
        end
      end
    end
  end

  def destroy
    if @physical_object.destroy
      flash[:notice] = "Physical Object was successfully deleted.".html_safe
    else
      flash[:notice] = "Physical Object could not be deleted.".html_safe
    end
    redirect_to physical_objects_path
  end
  
  def split_show
    if @physical_object.bin or @physical_object.box
      flash[:notice] = "This physical object must be removed from its container (bin or box) before it can be split."
      redirect_to action: :show
    else
      @count = 0;
      @display_assigned = true
    end
  end
  
  def split_update
    split_count = params[:count].to_i
    split_grouped = params[:grouped]
    if @physical_object.bin or @physical_object.box
      flash[:notice] = "This physical object must be removed from its container (bin or box) before it can be split."
      redirect_to action: :show
    elsif split_count > 1

      (1...split_count).each do |i|
        po = @physical_object.dup
        po.assign_default_workflow_status
        po.mdpi_barcode = 0
	if split_grouped
          po.group_position = @physical_object.group_position + i
	else
	  po.group_position = 1
	  po.group_key = nil
	end
        tm = @physical_object.technical_metadatum.as_technical_metadatum.dup
        tm.physical_object = po
        tm.save
        #po is automatically saved by association
      end

      flash[:notice] = "<i>#{@physical_object.title}</i> was successfully split into #{split_count} records.".html_safe
      if split_grouped
        redirect_to(controller: 'group_keys', action: "show", id: @physical_object.group_key)
      else
        redirect_to @physical_object
      end
    else
      flash[:notice] = "<i>#{@physical_object.title}</i> was NOT split.".html_safe
      redirect_to(controller: 'group_keys', action: "show", id: @physical_object.group_key)
    end
  end
  
  def upload_show
    @physical_object = PhysicalObject.new
  end
  
  def upload_update
    if params[:type].nil?
      flash[:notice] = "Please explicitly choose a picklist association (or lack thereof)."
    elsif params[:type].in? ["new", "existing"] and params[:picklist].nil?
      flash[:warning] = "SYSTEM ERROR: Picklist hash not passed."
    elsif params[:type] == "existing" and params[:picklist][:id].to_i.zero?
      flash[:notice] = "Please select an existing picklist."
    elsif params[:type] == "new" and params[:picklist][:name].to_s.blank?
      flash[:notice] = "Please provide a picklist name."
    elsif params[:physical_object].nil?
      flash[:notice] = "Please specify a file to upload."
    else
      @picklist = nil
      if params[:type] == "existing"
        @picklist = Picklist.find_by(id: params[:picklist][:id].to_i)
        flash[:warning] = "SYSTEM ERROR: Selected picklist not found!<br/>Spreadsheet NOT uploaded.".html_safe if @picklist.nil?
      elsif params[:type] == "new"
        @picklist = Picklist.new(name: params[:picklist][:name], description: params[:picklist][:description])
        @picklist.save
        flash[:warning] = "Errors creating picklist:<ul>#{@picklist.errors.full_messages.each.inject('') { |output, error| output += ('<li>' + error + '</li>') }}</ul>Spreadsheet NOT uploaded.".html_safe if @picklist.errors.any?
      end
    end
    if flash[:notice].to_s.blank? and flash[:warning].to_s.blank?
      path = params[:physical_object][:csv_file].path
      filename = params[:physical_object][:csv_file].original_filename
      header_validation = true unless params[:header_validation] == "false"
      upload_results = PhysicalObjectsHelper.parse_csv(path, header_validation, @picklist, filename)
      @spreadsheet = upload_results[:spreadsheet]
      flash[:notice] = "".html_safe
      flash[:notice] = "Created picklist: #{params[:picklist][:name]}.</br>".html_safe if @picklist and params[:type] == "new"
      flash[:notice] += ("Spreadsheet " + ((@spreadsheet.nil? || @spreadsheet.id.nil?) ? "NOT " : "")  + "uploaded.<br/>").html_safe
      flash[:notice] += "CSV headers NOT checked for validation.</br>".html_safe unless header_validation
      flash[:notice] += "#{upload_results['succeeded'].size} record" + (upload_results['succeeded'].size == 1 ? " was" : "s were") + " successfully imported.".html_safe
      if upload_results['failed'].size > 0
        @failed = upload_results['failed']
      end
    else
      redirect_to(action: 'upload_show')
    end
  end

  def create_multiple
    @physical_object = PhysicalObject.new
    #default format for now
    format = PhysicalObject.formats["CD-R"]
    @physical_object.format = format
    @tm = @physical_object.ensure_tm
    @digital_files = []
    @formats = PhysicalObject.formats
    @edit_mode = true
    @action = "create"
    @submit_text = "Create Physical Object"
    @repeat = true
    @display_assigned = false
  end
    
  def unbin
    unless @physical_object.box.nil?
      raise RuntimeError, "A physical object should not be unbin-able if it is in a box..."
    end
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

  #called as both AJAX call, from packing screen, and regular call from picklist screen
  def unpick
    # SEE - views/picklists/provess_list.html.erb "$("[id^=remove_]").click(function(event) {" javascript
    if @physical_object.group_key.nil?
      @physical_object.picklist = nil
      @physical_object.save
    else
      picklist_id = @physical_object.picklist_id
      @physical_object.group_key.physical_objects.each do |object|
        if object.picklist_id == picklist_id
          object.picklist = nil
          object.save
        end
      end
    end
    new_bc = Integer(params[:mdpi_barcode]) if params[:mdpi_barcode]
    update = (!new_bc.nil? and @physical_object.mdpi_barcode != new_bc)
    if (update)
      @physical_object.mdpi_barcode = new_bc
      update = @physical_object.save
    end
    flash[:notice] = "The Physical Object was removed from the Pick List" + (update ? " and its barcode updated." : ".")
    redirect_to action: "edit"
  end

  def ungroup
    @physical_object.group_position = 1
    @physical_object.group_key = nil
    if @physical_object.save
      flash[:notice] = "The Physical Object was removed from this Group Key."
    else
      flash[:notice] = "An error occurred.  Physical Object was NOT removed from this Group Key."
    end
    redirect_to :back
  end

  # ajax method to determine if a physical object has emphemera - returns plain text true/false
  def has_ephemera
    has_it = false
    if params[:mdpi_barcode] and (po = PhysicalObject.find_by(mdpi_barcode: params[:mdpi_barcode]))
      has_it = po.has_ephemera
    else
      has_it = "unknown physical Object"
    end
    render plain: "#{has_it}", layout: false
  end
  
  private
    def set_physical_object
      @physical_object = PhysicalObject.find(params[:id])
      @digital_files = @physical_object.digital_files
      @tm = @physical_object.technical_metadatum
      @tm = @physical_object.technical_metadatum.as_technical_metadatum unless @tm.nil?
      @bin = @physical_object.bin
      @box = @physical_object.box
      @group_key = @physical_object.group_key
    end

    def set_picklists
      @picklists = Picklist.all
    end
    
end
