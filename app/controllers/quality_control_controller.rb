class QualityControlController < ApplicationController

	def index
		if params[:status]
			@physical_objects = DigitalStatus.current_status(params[:status])
		end
	end

	def decide
		puts "WTF!?!?!?"
		debugger
		@ds = DigitalStatus.find(params[:id])
		@ds.update_attributes(decided: params[:decided])
		flash[:notice] = "Updated Digital Status for #{@ds.physical_object.mdpi_barcode} - chose #{@ds.decided}"
		render "index"
	end


end
