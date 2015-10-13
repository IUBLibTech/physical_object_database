class InvoiceController < ApplicationController
	before_action :set_submissions

	def index
	end

	def submit
		upload = params[:xls_file]
		if params[:xls_file].blank?
			flash.now[:notice] = "Please select an invoice to validate."
			render('invoice/index')
		else
			invoice = MemnonInvoiceSubmission.where("filename = ? AND successful_validation = true", upload.original_filename).first
			if invoice
				flash[:warning] = "#{upload.original_filename} was previously submitted successfully on #{invoice.submission_date.strftime("%m/%d/%Y %l:%M%P")}! Validation aborted..."
			else
				InvoiceHelper.parse_invoice(upload)
				flash[:notice] = "#{upload.original_filename} has been queued for validation. Refresh page to monitor status."
			end
			redirect_to invoice_controller_path
		end
	end

	def failed_message
		@mis = MemnonInvoiceSubmission.find(params[:id])
		render(partial: "invoice/failures")
	end
	

	private
	def set_submissions
		@file = ""
		@submissions = MemnonInvoiceSubmission.all().order("submission_date DESC")
		authorize :invoice
	end

end
