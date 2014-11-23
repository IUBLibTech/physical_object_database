class ReturnsController < ApplicationController
	before_action :set_bin, only: [:return_bin, :physical_object_returned, :bin_unpacked]

	def index
		@batches = Batch.where(workflow_status: "Returned")
	end

	def return_bins
		@batch = Batch.find(params[:id])
		@bins = @batch.bins
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

	def bin_unpacked
		# FIXME: handle boxes, boxed objects?
		unprocessed_objects = @bin.physical_objects.select { |po| !po.current_workflow_status.in?(["Unpacked", "Returned to Unit"]) and !po.has_condition?("Missing") }
		if unprocessed_objects.empty?
			@bin.update_attributes(current_workflow_status: 'Unpacked')
			redirect_to return_bins_return_path(@bin.batch)
		else
			flash[:notice] = ("<b class='warning'>There are #{unprocessed_objects.size} Physical Objects from this Bin that have either not been scanned for return or are missing. All missing items must have a condition status of <i>Missing</i> before a Bin can be marked as <i>Unpacked</i></b>").html_safe
			redirect_to return_bin_return_path(@bin)
		end
	end

	private
	def set_bin
		@bin = Bin.find(params[:id])
	end

end
