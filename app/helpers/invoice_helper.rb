module InvoiceHelper
	require 'roo'

	@@mutex = Mutex.new

	def self.parse_invoice(upload)
		Thread.new {
			@@mutex.synchronize do
				process(upload)
			end
		}
	end

	private
	def self.process(upload)
		debugger
		mis = MemnonInvoiceSubmission.new(filename: upload.original_filename, submission_date: Time.now, successful_validation: false, error_message: nil, validation_completion_percent: 0)
		debugger
		mis.save
		msg = ""
		xlsx = Roo::Excelx.new(upload.tempfile.path, file_warning: :ignore)
		xlsx.default_sheet = xlsx.sheets[0]

		headers = Hash.new
		xlsx.row(1).each_with_index {|header,i|
			headers[header] = i
		}
		debugger

		# step 1) check for a properly cased header row
		unless headers['Object barcode'].nil? or headers['Preservation master File name'].nil?
			msg = "#{upload.original_filename} contains inproperly formated headers: <b>'Object barcode'</b> and/or <b>'Preservation master File name'</b> not present.".html_safe
			mis.update_attributes(success: false, error_message: msg, validation_completion_percent: 100)
			return
		end

		# step 2) delete all the entries in the BillablePhysicalObject table (this table is essentially a 
		# temporary table and it's contents are only relevant in the context of the currently parsing invoice)
		BillablePhysicalObject.delete_all
		time = Time.now

		#spreadsheet first row index is #1 so total count is last_row - 1
		@total_pos = xlsx.last_row - 1

		# step 3) collect all candidate billable physical object barcodes
		@billable = Hash.new

		# step 4) collect all listed preservation master file names. A preservation master file name can only appear
		# once in the invoice or the invoice is invalid
		@preservation_files = Set.new
		@preservation_file_copies = Set.new

		debugger
		((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
			#date_delivered = xlsx.row(row)[headers['Delivery check date']]
			barcode = xlsx.row(row)[headers['Object barcode']].to_i
			pres_file = xlsx.row(row)[headers['Preservation master File name']]
			# -2 because the first row index is 1 AND the first row is header values
			@billable[barcode] = barcode

			if @preservation_files.add?(pres_file).nil?
				@preservation_file_copies.add(pres_file)
			end
		end
		
		# step 5) populate the temporary table which contains all billable candidates. this table will be joined against
		# physical_objects to determine what files have already been billed.
		@billable.keys.each do |barcode|
			BillablePhysicalObject.new(mdpi_barcode: barcode, delivery_date: time).save
		end

		# step 6) run query to determine if anything listed has already been billed
		@already_billed = PhysicalObject.find_by_sql(
			"SELECT physical_objects.mdpi_barcode, physical_objects.spread_sheet_filename, physical_objects.date_billed 
			FROM physical_objects, billable_physical_objects
			WHERE physical_objects.mdpi_barcode = billable_physical_objects.mdpi_barcode AND physical_objects.billed = true"
		)

		# step 7) search for any source recording barcodes that are not in the POD - obviously we shouldn't be billed 
		# for something that doesn't exist...
		@not_found = BillablePhysicalObject.find_by_sql(
			"SELECT billable_physical_objects.mdpi_barcode
			FROM billable_physical_objects LEFT JOIN physical_objects ON billable_physical_objects.mdpi_barcode = physical_objects.mdpi_barcode
			WHERE physical_objects.id IS NULL"
		)

		# step 8) run query against physical objects that have not started the digitization process - this means they are no
		# on SDA yet, and thus, cannot be billed
		@not_on_sda = PhysicalObject.find_by_sql(
			"SELECT physical_objects.mdpi_barcode 
			FROM physical_objects, billable_physical_objects
			WHERE physical_objects.mdpi_barcode = billable_physical_objects.mdpi_barcode AND physical_objects.billed = true AND physical_objects.digital_start is NULL"
		)
		debugger
		if @already_billed.size > 0 or @not_found.size > 0 or @not_on_sda.size > 0 or @preservation_file_copies.size > 0
			msg = ActionView::Base.new('app/views').render(file: 'invoice/failures')
			mis.update_attributes(successful_validation: false, error_message: msg, validation_completion_percent: 100)
		else
			begin 
				mis.update_attributes(successful_validation: true, validation_completion_percent: 50).save
				PhysicalObject.transaction do
					@billable.each do |barcode|
						#update_attributes will not throw and exception (the only thing that triggers a rollback in rails) - must use update_attributes!
						po = PhysicalObject.where(mdpi_barcode: barcode).where.not(digital_start: nil).first
						po.update_attributes!(billed: true, spread_sheet_filename: upload.original_filename, date_billed: time)
					end
					mis.update_attributes!(validation_completion_percent: 100)
				end
			rescue => error
				mis.update_attributes(error_message: error.backtrace.to_s, successful_validation: false, validation_completion_percent: 100)
			end
		end
	end
end
