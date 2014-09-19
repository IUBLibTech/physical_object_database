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
		@returned = WorkflowStatusQueryModule.in_bin_where_current_status_is(@bin, "Returned").sort{|a,b| a.call_number <=> b.call_number}
		@shipped = WorkflowStatusQueryModule.in_bin_where_current_status_is(@bin, "Shipped").sort{|a,b| a.call_number <=> b.call_number}
	end

	def physical_object_missing
		
	end

	def physical_object_returned
		puts params.to_yaml
		@bin = Bin.find(params[:id])
		po = PhysicalObject.where(mdpi_barcode: params[:mdpi_barcode])[0]

		if po.nil?
			flash[:notice] = "<b class='warning'>No Physical Object with barcode #{params[:mdpi_barcode]} was found.</b>".html_safe
		elsif po.bin.nil? or po.bin != @bin
			flash[:notice] = "<b class='warning'>Physical Object with barcode <a href='#{physical_object_path(po.id)}' target='_blank'>#{po.mdpi_barcode}</a> was not originally shipped with this bin!</b>".html_safe
		else
			po.update_attributes(current_workflow_status: "Returned", ephemera_returned: params[:ephemera_returned][:ephemera_returned])
			msg = "Physical Object with barcode #{po.mdpi_barcode} was successfully returned. ".html_safe +
			(po.has_ephemera ? (po.ephemera_returned ? "Its ephemera was also returned." : "<b class='warning'>Its ephemera was NOT returned.</b>".html_safe) : "")
			flash[:notice] = msg
		end
		redirect_to(action: 'return_bin', id: @bin.id)
	end

	def bin_unpacked
		@bin = Bin.find(params[:id])
		# every item that was shipped in the bin must have a status of "Returned" OR those items that do not have a status of
		# returned must have a condition status of "Not Returned"
		returned = WorkflowStatusQueryModule.in_bin_where_current_status_is(@bin, "Returned")
		if (returned == @bin.physical_objects)
			@bin.update_attributes(current_workflow_status: 'Returned Complete')
			redirect_to return_bins_return_path(@bin.batch)
		else
			# if all the missing items have been flagged as "Not Returned" we can mark the bin as 'Returned Incomplete' otherwise redirect back
			# to the packing screen
			unmarked = []
			(@bin.physical_objects - returned).each do |bad|
				if !ConditionStatusModule.has_condition?(bad, 'Not Returned')
					unmarked << bad
				end
			end
			if unmarked.size > 0
				flash[:notice] = ("<b class='warning'>There are #{unmarked.size} Physical Objects from this Bin that have either not been scanned for return " <<
				" or are missing. All missing items must have a condition status of <i>Not Returned</i> before a Bin can be marked as <i>Unpacked</i></b>").html_safe
				redirect_to return_bin_return_path(@bin)
			else
				@bin.update_attributes(current_workflow_status: 'Returned Incomplete')
				redirect_to return_bins_return_path(@bin.batch)
			end
		end
	end

end
