class GroupKeysController < ApplicationController
  before_action :set_group_key, only: [:show, :edit, :update, :destroy]

  # GET /group_keys
  # GET /group_keys.json
  def index
    @group_keys = GroupKey.all
  end

  # GET /group_keys/1
  # GET /group_keys/1.json
  def show
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_key
      @group_key = GroupKey.find(params[:id])
      @physical_objects = @group_key.physical_objects.order(:group_position)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_key_params
      params.require(:group_key).permit(:group_total)
    end
end
