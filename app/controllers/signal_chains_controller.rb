class SignalChainsController < ApplicationController
  before_action :set_signal_chain, only: [:show, :edit, :update, :destroy]

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

  # DELETE /signal_chains/1
  # DELETE /signal_chains/1.json
  def destroy
    @signal_chain.destroy
    respond_to do |format|
      format.html { redirect_to signal_chains_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_signal_chain
      @signal_chain = SignalChain.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def signal_chain_params
      params.require(:signal_chain).permit(:name)
    end
end
