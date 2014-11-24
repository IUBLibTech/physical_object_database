class ReturnsController < ApplicationController
	before_action :set_batch, only: [:return_bins, :batch_complete]
	before_action :set_bin, only: [:return_bin, :physical_object_returned, :bin_unpacked, :unload_bin]

	def index
		@batches = Batch.where(workflow_status: "Returned")
	end

	def return_bins
		# renders template
	end

	def return_bin
		@returned = PhysicalObject.where(bin_id: @bin.id, workflow_status: ["Unpacked", "Returned to Unit"]).order(:call_number)
		@shipped = PhysicalObject.where(bin_id: @bin.id, workflow_status: "Binned").order(:call_number)
	end

        # FIXME: deprecated?
	def physical_object_missing
		
	end

	def physical_object_returned
		po = PhysicalObject.find_by(mdpi_barcode: params[:mdpi_barcode])

		if po.nil?
			flash[:notice] = "<b class='warning'>No Physical Object with barcode #{params[:mdpi_barcode]} was found.</b>".html_safe
		elsif po.bin.nil? or po.bin != @bin
			flash[:notice] = "<b class='warning'>Physical Object with barcode <a href='#{physical_object_path(po.id)}' target='_blank'>#{po.mdpi_barcode}</a> was not originally shipped with this bin!</b>".html_safe
		else
                        # FIXME: discern nil/false value for ephemera_returned?
			po.update_attributes(current_workflow_status: "Unpacked", ephemera_returned: params[:ephemera_returned][:ephemera_returned])
			msg = "Physical Object with barcode #{po.mdpi_barcode} was successfully returned. ".html_safe +
			(po.has_ephemera ? (po.ephemera_returned ? "Its ephemera was also returned." : "<b class='warning'>Its ephemera was NOT returned.</b>".html_safe) : "")
			flash[:notice] = msg
		end
		redirect_to(action: 'return_bin', id: @bin.id)
	end

	def unload_bin
		if @bin.batch.nil?
			flash[:notice] = "<b class='warning'>This bin is not associated to a batch.</b>".html_safe
		elsif @bin.current_workflow_status == "Batched"
			@bin.current_workflow_status = "Returned to Staging Area"
			if @bin.save
				flash[:notice] = "Bin has been successfully Returned to Staging Area."
			else
				flash[:notice] = "<b class='warning'>Error updating Bin workflow status.</b>".html_safe

			end
		elsif @bin.current_workflow_status.in? ["Returned to Staging Area", "Unpacked"]
			flash[:notice] = "This Bin has already been unloaded from the Batch.  No action taken.".html_safe
		else
			flash[:notice] = "<b class='warning'>This Bin has an unknown workflow status of #{@bin.current_workflow_status}.</b>".html_safe

		end
		redirect_to :back
	end

	def batch_complete
	  if @batch.current_workflow_status == "Complete" 
	    flash[:notice] = "The batch is already in a status of Complete.  No action taken."
	    success = true
	  elsif @batch.current_workflow_status == "Returned" and @batch.bins.all? { |bin| bin.current_workflow_status == "Unpacked" }
	    @batch.current_workflow_status = "Complete"
	    if @batch.save
              flash[:notice] = "The Batch workflow status was successfully updated to Complete."
	      success = true
            else
              flash[:notice] = "<b class='warning'>There was an error updating the status of the Batch</b>".html_safe
            end
	  else
	    flash[:notice] = "<b class='warning'>The batch cannot be marked Complete unless it is in a status of Returned and all associated bins have a status of Unpacked.</b>".html_safe
	  end
	  if success
            redirect_to returns_path
	  else
	    redirect_to return_bins_return_path(@batch)
          end
	end

	# FIXME: handle boxes, boxed objects?
	def bin_unpacked
	  case @bin.current_workflow_status
	  when "Unpacked"
	    flash[:notice] = "Bin has already been marked Unpacked.  No action taken."
	    redirect_to return_bins_return_path(@bin.batch)
	  when "Returned to Staging Area"
	    unprocessed_objects = @bin.physical_objects.select { |po| !po.current_workflow_status.in?(["Unpacked", "Returned to Unit"]) and !po.has_condition?("Missing") }
	    if unprocessed_objects.empty?
	      @bin.update_attributes(current_workflow_status: 'Unpacked')
	      redirect_to return_bins_return_path(@bin.batch)
	    else
	      flash[:notice] = ("<b class='warning'>There are #{unprocessed_objects.size} Physical Objects from this Bin that have either not been scanned for return or are missing. All missing items must have a condition status of <i>Missing</i> before a Bin can be marked as <i>Unpacked</i></b>").html_safe
	      redirect_to return_bin_return_path(@bin)
	    end
	  else
	    flash[:notice] = "<b class='warning>A Bin cannot be marked Unpacked with a workflow status of #{@bin.current_workflow_status}</b>".html_safe
	    redirect_to return_bins_return_path(@bin.batch)
	  end
	end

	private
	def set_batch
		@batch = Batch.find(params[:id])
		@bins = @batch.bins
	end

	def set_bin
		@bin = Bin.find(params[:id])
	end

end
