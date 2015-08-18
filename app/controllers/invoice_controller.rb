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
		@billable = Hash.new
		((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
			#date_delivered = xlsx.row(row)[headers['Delivery check date']]
			barcode = xlsx.row(row)[headers['Object barcode']].to_i

			# -2 because the first row index is 1 AND the first row is header values
			@billable[barcode] = barcode
		end
		
		@billable.keys.each do |barcode|
			BillablePhysicalObject.new(mdpi_barcode: barcode, delivery_date: time).save
		end

		@failed = PhysicalObject.find_by_sql(
			"SELECT physical_objects.mdpi_barcode, physical_objects.spread_sheet_filename, physical_objects.date_billed 
			FROM physical_objects, billable_physical_objects
			WHERE physical_objects.mdpi_barcode = billable_physical_objects.mdpi_barcode AND physical_objects.billed = true"
		)
		@not_found = BillablePhysicalObject.find_by_sql(
			"SELECT billable_physical_objects.mdpi_barcode
			FROM billable_physical_objects LEFT JOIN physical_objects ON billable_physical_objects.mdpi_barcode = physical_objects.mdpi_barcode
			WHERE physical_objects.id IS NULL"
		)
		if @failed.size > 0
			flash.now[:warning] = "Billing failed because #{@failed.size} of the #{@total_pos} Physical Objects have already been billed:"
			render 'failed'
		elsif @not_found.size > 0
			flash.now[:warning] = "Billing failed because #{@not_found.size} of the #{@total_pos} MDPI barcodes submitted did not find matching Physical Objects:"
			render 'not_found'
		else
			begin 
				PhysicalObject.transaction do
					@billable.each do |barcode|
						#update_attributes will not throw and exception (the only thing that triggers a rollback in rails) - must use update_attributes!
						po = PhysicalObject.where(mdpi_barcode: barcode).where.not(digital_start: nil).first
						unless po.nil?
							po.update_attributes!(billed: true, spread_sheet_filename: upload.original_filename, date_billed: time)
						else
						end
						flash.now[:notice] = "All #{@total_pos} Physical Objects for #{upload.original_filename} have been marked as billed."
						@file = ""
						render 'index'
					end
				end
			rescue => error
				error.backtrace
				flash.now[:warning] = "An unexpected error occurred while processing the invoice - <b>No records were marked as billed </b>".html_safe
				@file = ""
				render 'failed'
			end
		end
	end

end
