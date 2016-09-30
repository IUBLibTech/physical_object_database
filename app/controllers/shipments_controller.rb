class ShipmentsController < ApplicationController
  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :unload, :unload_object, :reload, :reload_object]
  before_action :authorize_collection, only: [:index, :new, :create, :shipments_list, :new_shipment]
  before_action :set_po, only: [:unload_object, :reload_object]
  before_action :set_shipment_dropdown, only: [:shipments_list]

  # GET /shipments
  # GET /shipments.json
  def index
    @shipments = Shipment.all
  end

  # GET /shipments/1
  # GET /shipments/1.json
  def show
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
  end

  def new_shipment
    render(partial: 'new_shipment')
  end

  def shipments_list
    render(partial: "shipments_list")
  end

  # GET /shipments/1/edit
  def edit
  end

  # POST /shipments
  # POST /shipments.json
  def create
    @shipment = Shipment.new(shipment_params)

    respond_to do |format|
      if @shipment.save
        format.html { redirect_to @shipment, notice: 'Shipment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shipment }
      else
        format.html { render action: 'new' }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipments/1
  # PATCH/PUT /shipments/1.json
  def update
    respond_to do |format|
      if @shipment.update(shipment_params)
        format.html { redirect_to @shipment, notice: 'Shipment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipments/1
  # DELETE /shipments/1.json
  def destroy
    @shipment.destroy
    respond_to do |format|
      format.html { redirect_to shipments_url }
      format.json { head :no_content }
    end
  end

  def unload
    @unprocessed = @to_be_unloaded
    @processed = @unloaded
  end

  def unload_object
    if @po.nil?
      flash[:warning] = "No Physical Object with barcode #{params[:mdpi_barcode]} was found.".html_safe
    elsif @po.shipment != @shipment
      flash[:warning] = "Physical Object with barcode <a href='#{physical_object_path(@po.id)}' target='_blank'>#{@po.mdpi_barcode}</a> was not originally sent in this Shipment!".html_safe
    elsif !@po.picklist.nil?
      flash[:notice] = 'This physical object had already been unloaded.  No action taken.'
    else
      @po.update_attributes(picklist: @shipment.picklist_for_format(@po.format))
      flash[:notice] = "This physical object has been assigned to the picklist: #{@po.picklist.name}"
    end
    redirect_to :back
  end

  def reload
    @unprocessed = @to_be_reloaded
    @processed = @reloaded
  end

  def reload_object
    if @po.nil?
      flash[:warning] = "No Physical Object with barcode #{params[:mdpi_barcode]} was found.".html_safe
    elsif @po.shipment != @shipment
      flash[:warning] = "Physical Object with barcode <a href='#{physical_object_path(@po.id)}' target='_blank'>#{@po.mdpi_barcode}</a> was not originally sent in this Shipment!".html_safe
    elsif @po.workflow_status == 'Returned to Unit'
      flash[:notice] = "This physical object has already been repacked.  No action taken."
    elsif @po.workflow_status != 'Unpacked'
      flash[:warning] = "This physical object cannot be repacked with a status of: #{@po.workflow_status}".html_safe
    else
      @po.update_attributes(current_workflow_status: 'Returned to Unit')
      flash[:notice] = "This physical object has has its workflow status updated to 'Returned to Unit'"
    end
    redirect_to :back
  end

  private
    def set_shipment
      @shipment = Shipment.find(params[:id])
      authorize @shipment
      @physical_objects = @shipment.physical_objects.order(:workflow_index) if @shipment
      if @physical_objects
        @to_be_unloaded = @physical_objects.where(workflow_index: 1)
        @unloaded = @physical_objects.where(workflow_index: 2)
        @in_progress = @physical_objects.where(workflow_index: [3,4])
        @to_be_reloaded = @physical_objects.where(workflow_index: 5)
        @reloaded = @physical_objects.where(workflow_index: 6)
      end
      @picklists = @shipment.picklists.order(:name) if @shipment
    end

    def authorize_collection
      authorize Shipment
    end

    def shipment_params
      params.require(:shipment).permit(:identifier, :description, :physical_location, :unit_id)
    end

    def set_po
      @po = PhysicalObject.find_by(mdpi_barcode: params[:mdpi_barcode])
    end

    def set_shipment_dropdown
      if @pundit_user&.unit
        @shipments = Shipment.where(unit_id: @pundit_user&.unit&.id).order('identifier').collect{ |s| [s.identifier, s.id] }
      else
        @shipments = Shipment.all.order('identifier').collect{ |s| [s.identifier, s.id] }
      end
    end

end
