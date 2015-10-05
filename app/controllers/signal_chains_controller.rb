class SignalChainsController < ApplicationController
  before_action :set_signal_chain, only: [:show, :edit, :update, :destroy, :include, :reorder]
  before_action :authorize_collection, only: [:index, :new, :create]

  # GET /signal_chains
  # GET /signal_chains.json
  def index
    @signal_chains = SignalChain.all
  end

  # GET /signal_chains/1
  # GET /signal_chains/1.json
  def show
  end

  # GET /signal_chains/new
  def new
    @signal_chain = SignalChain.new
  end

  # GET /signal_chains/1/edit
  def edit
  end

  # POST /signal_chains
  # POST /signal_chains.json
  def create
    @signal_chain = SignalChain.new(signal_chain_params)

    respond_to do |format|
      if @signal_chain.save
        format.html { redirect_to @signal_chain, notice: 'Signal chain was successfully created.' }
        format.json { render action: 'show', status: :created, location: @signal_chain }
      else
        format.html { render action: 'new' }
        format.json { render json: @signal_chain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /signal_chains/1
  # PATCH/PUT /signal_chains/1.json
  def update
    respond_to do |format|
      if @signal_chain.update(signal_chain_params)
        format.html { redirect_to @signal_chain, notice: 'Signal chain was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @signal_chain.errors, status: :unprocessable_entity }
      end
    end
  end

  def include
    step = @signal_chain.processing_steps.new(machine_id: params[:machine_id], position: params[:position])
    if step.save
      flash[:notice] = "Processing step was successfully added."
    else
      flash[:warning] = "Error adding processing step: #{step.errors.full_messages}"
    end
    redirect_to :back
  end

  def reorder
    reorder_param = params[:reorder_submission]
    if reorder_param.nil? || reorder_param.blank?
      flash[:notice] = "No changes submitted."
    else
      reorder_ids = reorder_param.split(",")
      objects = []
      errors = false
      reorder_ids.each_with_index do |step_id, index|
        processing_step = ProcessingStep.where(id: step_id, signal_chain_id: @signal_chain.id)[0]
        unless processing_step.nil?
          processing_step.position = index + 1
          objects << processing_step
        end
      end
      #loop in reverse order to minimize resolve_group_position effects
      objects.reverse_each do |step|
        errors = step.errors unless step.save(validate: false)
      end
      if errors
        flash[:notice] = "Errors encountered reordering objects: #{errors.full_messages}"
      else
        flash[:notice] = "Objects were successfully reordered."
      end
    end
    redirect_to :back
  end

  # DELETE /signal_chains/1
  # DELETE /signal_chains/1.json
  def destroy
    @signal_chain.destroy
    respond_to do |format|
      format.html { redirect_to signal_chains_url }
      format.json { head :no_content }
    end
  end

  def ajax_show
    # regex to make sure that the passed in value is an INTEGER (so it can be looked up) - if the select on the form is 
    # left blank "No Select Value" will be in the params[:id] slot
    if !!(params[:id] =~ /\A[-+]?[0-9]+\z/)
      @signal_chain = SignalChain.where(id: params[:id]).first
    end
    render(partial: 'ajax_show_signal_chain')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_signal_chain
      @signal_chain = SignalChain.find(params[:id])
      authorize @signal_chain
    end

    def authorize_collection
      authorize SignalChain
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def signal_chain_params
      params.require(:signal_chain).permit(:name)
    end
end
