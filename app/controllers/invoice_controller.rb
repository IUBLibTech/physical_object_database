class InvoiceController < ApplicationController
	require 'roo'

	def index
		@file = ""
	end

	def submit
		upload = params[:xls_file]
		xlsx = Roo::Excelx.new(upload.tempfile.path, file_warning: :ignore)
		xlsx.default_sheet = xlsx.sheets[0]

		headers = Hash.new
		xlsx.row(1).each_with_index {|header,i|
			headers[header] = i
		}

		# before running this spreadsheet, delete all the entries in the BillablePhysicalObject table - this 
		# table is essentially a temporary table and it's contents are only used in the context of the currently
		# loaded spreadsheet
		BillablePhysicalObject.delete_all
		time = Time.now

		#spreadsheet first row index is #1 so total count is last_row - 1
		@total_pos = xlsx.last_row - 1
		@billable = Array.new(@total_pos)
		((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
			#date_delivered = xlsx.row(row)[headers['Delivery check date']]
			barcode = xlsx.row(row)[headers['Object barcode']].to_i

			# -2 because the first row index is 1 AND the first row is header values
			@billable[row - 2] = barcode
			BillablePhysicalObject.new(mdpi_barcode: barcode, delivery_date: time).save
		end

		@failed = PhysicalObject.find_by_sql(
			"SELECT physical_objects.mdpi_barcode, physical_objects.spread_sheet_filename, physical_objects.date_billed 
			FROM physical_objects, billable_physical_objects
			WHERE physical_objects.mdpi_barcode = billable_physical_objects.mdpi_barcode AND physical_objects.billed = true"
		)
		
		if @failed.size > 0
			flash.now[:warning] = "Billing failed because #{@failed.size} of the #{@total_pos} Physical Objects have already been billed:"
			render 'failed'
		else
			@billable.each do |barcode|
				PhysicalObject.where(mdpi_barcode: barcode).first.update_attributes(billed: true, spread_sheet_filename: upload.original_filename, date_billed: time)
			end
			flash.now[:notice] = "All #{@total_pos} Physical Objects for #{upload.original_filename} have been marked as billed."
			@file = ""
			render 'index'
		end
	end

end
