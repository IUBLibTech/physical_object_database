class ProcessingStepsController < ApplicationController
  before_action :set_processing_step, only: [:destroy]

  # DELETE /signal_chains/1
  # DELETE /signal_chains/1.json
  def destroy
    if @processing_step.destroy
      flash[:notice] = "Processing step successfully destroyed."
    else
      flash[:warning] = "Processing step was NOT destroyed."
    end
    redirect_to :back
  end

  private
  def set_processing_step
    @processing_step = ProcessingStep.find(params[:id])
  end

end
