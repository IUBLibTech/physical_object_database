class GroupKeysController < ApplicationController
  before_action :set_group_key, only: [:show, :edit, :update, :destroy, :reorder, :include]
  before_action :authorize_collection, only: [:index, :new, :create]

  # GET /group_keys
  # GET /group_keys.json
  def index
    @group_keys = GroupKey.all
    if request.format.html?
      @group_keys = @group_keys.paginate(page: params[:page])
    end
  end

  # GET /group_keys/1
  # GET /group_keys/1.json
  def show
    if request.format.html? 
      @physical_objects = @physical_objects.paginate(page: params[:page])
    end
  end

  # GET /group_keys/new
  def new
    @group_key = GroupKey.new
    @edit_mode = true
    @action = "create"
    @submit_text = "Create Group Key"
  end

  # GET /group_keys/1/edit
  def edit
    @edit_mode = true
    @action = "update"
    @submit_text = "Update Group Key"
  end

  # POST /group_keys
  # POST /group_keys.json
  def create
    @group_key = GroupKey.new(group_key_params)

    respond_to do |format|
      if @group_key.save
        format.html { redirect_to @group_key, notice: 'Group key was successfully created.' }
        format.json { render action: 'show', status: :created, location: @group_key }
      else
        format.html do
	  @edit_mode = true
	  @action = "create"
	  @submit_text = "Create Group Key"
	  render 'new'
	end
        format.json { render json: @group_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /group_keys/1
  # PATCH/PUT /group_keys/1.json
  def update
    respond_to do |format|
      if @group_key.update(group_key_params)
        format.html { redirect_to @group_key, notice: 'Group key was successfully updated.' }
        format.json { head :no_content }
      else
        format.html do
	  @edit_mode = true
	  @action = "update"
	  @submit_text = "Update Group Key"
	  render action: 'edit'
	end
        format.json { render json: @group_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_keys/1
  # DELETE /group_keys/1.json
  def destroy
    @group_key.destroy
    respond_to do |format|
      format.html { redirect_to group_keys_url }
      format.json { head :no_content }
    end
  end

  # PATCH reorder
  def reorder
    reorder_param = params[:reorder_submission]
    if reorder_param.nil? || reorder_param.blank?
      flash[:notice] = "No changes submitted."
    else
      reorder_ids = reorder_param.split(",")
      objects = []
      errors = false
      reorder_ids.each_with_index do |object_id, index|
        physical_object = PhysicalObject.where(id: object_id, group_key_id: @group_key.id)[0]
	unless physical_object.nil? 
	  physical_object.group_position = index + 1
	  objects << physical_object
	end
      end
      #loop in reverse order to minimize resolve_group_position effects
      objects.reverse_each do |physical_object|
        errors = true unless physical_object.save
      end
      if errors
        flash[:notice] = "Errors encountered reordering objects."
      else
        flash[:notice] = "Objects were successfully reordered."
      end
    end
    redirect_to :back
  end

  def include
    mdpi_barcode = params[:mdpi_barcode].to_i
    mdpi_barcode ||= 0
    group_position = params[:group_position].to_i
    group_position ||= 1
    if mdpi_barcode.zero?
      flash[:warning] = "You must specify a valid, non-zero MPDI barcode."
    else
      physical_object = PhysicalObject.where(mdpi_barcode: mdpi_barcode).first
      if physical_object
        physical_object.group_key = @group_key
	physical_object.group_position = group_position
        if physical_object.save
	  flash[:notice] = "Physical object was successfully moved into specificed position within this Group Key."
	else
	  flash[:warning] = "Problem saving Physical Object."
	end
      else
        flash[:warning] = "No matching physical object was found."
      end
    end
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_key
      @group_key = GroupKey.find(params[:id])
      authorize @group_key
      @physical_objects = @group_key.physical_objects.order(:group_position)
    end

    def authorize_collection
      authorize GroupKey
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_key_params
      params.require(:group_key).permit(:group_total)
    end
end
