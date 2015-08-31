class InvoiceController < ApplicationController
	require 'roo'
	include 'InvoiceHelper'

	before_action :set_submissions

	def index
		
	end

	def submit
		upload = params[:xls_file]
		invoice = MemnonInvoiceSubmission.find_by(filename: upload.original_filename, success: true)
		if invoice
			flash.now[:warning] = "#{upload.original_filename} was previously submitted successfully on #{invoice.submission_date}! Validation aborted..."
		else
			parse_invoice(upload)
			flash.now[:notice] = "#{upload.original_filename} has been queued for validation. Refresh page to monitor status."
		end
	end
	

	private
	def set_submissions
		@file = ""
		@submissions = MemnonInvoiceSubmission.all().order(:submission_date)
	end

end
