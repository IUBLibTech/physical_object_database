class ReturnsController < ApplicationController

	def index
		@batches = WorkflowStatusQueryModule.where_current_status_is(Batch, "Returned")
	end

	def return_bins
		@batch = Batch.find(params[:id])
		@bins = @batch.bins
	end

	def return_bin
		@bin = Bin.find(params[:id])
		
	end

end
