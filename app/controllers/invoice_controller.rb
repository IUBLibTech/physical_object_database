class InvoiceController < ApplicationController
	before_action :set_submissions

	def index
		
	end

	def submit
		upload = params[:xls_file]
		invoice = MemnonInvoiceSubmission.find_by(filename: upload.original_filename, successful_validation: true)
		if invoice
			flash.now[:warning] = "#{upload.original_filename} was previously submitted successfully on #{invoice.submission_date}! Validation aborted..."
		else
			InvoiceHelper.parse_invoice(upload)
			flash.now[:notice] = "#{upload.original_filename} has been queued for validation. Refresh page to monitor status."
		end
		redirect_to invoice_controller_path
	end
	

	private
	def set_submissions
		@file = ""
		@submissions = MemnonInvoiceSubmission.all().order(:submission_date)
	end

end
