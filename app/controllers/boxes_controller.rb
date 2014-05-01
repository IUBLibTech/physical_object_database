class BoxesController < ApplicationController


	def destroy
		box = Box.find(params[:id])
		if box.destroy
			flash[:notice] = "Successfully deleted Box: #{box.mdpi_barcode}"
			redirect_to bins_path
		else
			flash[:notice] = "<b>Failed to delete Box: #{box.mdpi_barcode}</b>".html_safe
			render('show')
		end
	end

end
