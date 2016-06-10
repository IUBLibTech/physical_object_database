class BoxesController < ApplicationController
  before_action :set_bin
  before_action :set_box, only: [:show, :edit, :update, :destroy, :unbin]
  before_action :authorize_collection, only: [:index, :new, :create]

  def index
    if @bin
      @boxes = Box.where(bin_id: @bin.id).order(full: :desc)
    elsif [:tm_format, :description].map { |att| params[att].nil? }.all?
      @boxes = Box.none
    else
      @boxes = Box.all.order(full: :desc)
      @boxes = @boxes.where(bin_id: [0, nil]) if params[:assignment] == 'unassigned'
      @boxes = @boxes.where.not(bin_id: [0, nil]) if params[:assignment] == 'assigned'
      @boxes = @boxes.where(format: params[:tm_format]) unless params[:tm_format].blank?
      @boxes = @boxes.where.like(description: '%' + params[:description] + '%') unless params[:description].blank?
    end
  end

  def show
    @picklists = Picklist.where("complete = false").order('name').collect{|p| [p.name, p.id]}
    if request.format.html?
      @physical_objects = @physical_objects.paginate(page: params[:page])
    end
  end

  def new
    @bins = Bin.all
    if @bin
      @box = @bin.boxes.new(mdpi_barcode: 0)
    else
      @box = Box.new
    end
  end

  def create
    @bins = Bin.all
    if @bin
      @box = @bin.boxes.new(box_params)
    else
      @box = Box.new(box_params)
    end

    respond_to do |format|
      if @box.save
        format.html { redirect_to @box, notice: 'Box was successfully created.' }
        format.json { render action: 'show', status: :created, location: @box }
      else
        format.html { render action: 'new' }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    if request.format.html?
      @physical_objects = @physical_objects.paginate(page: params[:page])
    end
  end

  def update
    respond_to do |format|
      if @box.update(box_params)
        format.html { redirect_to @box, notice: 'Box was successfully updated.' }
        format.json { render action: 'show', status: :created, location: @box }
      else
        format.html { @edit_mode = true; render action: :edit }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @box.destroy
      flash[:notice] = "Successfully deleted Box: #{@box.mdpi_barcode}"
      redirect_to bins_path
    else
      flash[:notice] = "<b>Failed to delete Box: #{@box.mdpi_barcode}</b>".html_safe
      render('show')
    end
  end

  def unbin
    if @box.bin.nil?
      flash[:warning] = "Box was not associated to a Bin.".html_safe
    elsif @bin and @box.bin != @bin
      flash[:warning] = "Box is associated to a different Bin.".html_safe
    else 
      @box.bin = nil
      if @box.save
	flash[:notice] = "<em>Successfully removed Box from Bin.</em>".html_safe
      else
        flash[:warning] = "Failed to remove this Box from Bin.".html_safe
      end
    end
    unless @bin.nil?
      redirect_to @bin
    else
      redirect_to @box
    end
  end

  private
    def set_bin
      @bin = (params[:bin_id].nil? ? nil : Bin.find(params[:bin_id]))
    end
    def set_box
      @box = Box.find(params[:id])
      authorize @box
      @bins = Bin.all
      @physical_objects = PhysicalObject.includes(:group_key, :unit, :box).where(box_id: @box.id).references(:group_key).packing_sort
    end
    def box_params
      params.require(:box).permit(:mdpi_barcode, :spreadsheet, :spreadsheet_id, :bin, :bin_id, :full, :description, :format)
    end
    def authorize_collection
      authorize Box
    end
end
