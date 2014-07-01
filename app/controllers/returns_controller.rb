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
		@returned = WorkflowStatusQueryModule.in_bin_where_current_status_is(@bin, "Returned")
		@shipped = WorkflowStatusQueryModule.in_bin_where_current_status_is(@bin, "Returned")
	
	end

end
