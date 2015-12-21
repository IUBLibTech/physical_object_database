module InvoiceHelper
	require 'roo'


	@@mutex = Mutex.new

	def self.parse_invoice(upload)
		Thread.new {
			@@mutex.synchronize do
				process_rows(upload)
			end
		}
	end

	def self.process_rows(upload)
		mis = MemnonInvoiceSubmission.new(filename: upload.original_filename, submission_date: Time.now, successful_validation: false, validation_completion_percent: 0)
		mis.save
		puts "Starting invoice parse..."
		begin
			xlsx = Roo::Excelx.new(upload.tempfile.path, file_warning: :ignore)
			xlsx.default_sheet = xlsx.sheets[0]

			time = Time.now

			headers = Hash.new
			# items that can be potentially billed
			@billable = Array.new
			# a set containing all preservation master filenames to determine in something is being double billed
			@preservation_files = Set.new
			# the rows that have problems and the problem with the row formatted: "row number: problem"
			@problems_by_row = Array.new

			# 1) check to see that the headers are present and properly cased
			xlsx.row(1).each_with_index {|header,i|
				headers[header] = i
			}
			if headers['Object barcode'].nil? or headers['Preservation master File name'].nil?
				mis.update_attributes(successful_validation: false, bad_headers: true, validation_completion_percent: 100)
				return
			end

			# 2) iterate through all rows and check
			#   a) is the barcode or pres filename missing?
			#   b) is the filename a duplicate of another row?
			#   c) has the physical object already been billed?
			#   d) is the physical object a valid physical object?
			#   e) is the physical object on SDA?
			((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
				barcode = xlsx.row(row)[headers['Object barcode']].to_i
				puts "row #{row}: #{barcode}"
				pres_filename = xlsx.row(row)[headers['Preservation master File name']]
				po = PhysicalObject.where(mdpi_barcode: barcode).first
				problem = ""
				problem << "bad barcode [#{barcode}]" if po.nil?
				problem << "missing barcode, " if barcode.blank?
				problem << "missing preservation master filename, " if pres_filename.blank?
				problem << "duplicate preservation master filename, " if @preservation_files.add?(pres_filename).nil?
				unless po.nil?
					problem << "already billed, " if po.billed
				end
				unless po.nil?
					problem << "not on SDA" if po.digital_start.nil?
				end
				if problem.length > 0
					@problems_by_row << "row #{row}: #{problem}" if problem.length > 0
 				else
					@billable << barcode
				end
			end
			puts "Problems checked"
			mis.update_attributes(problems_by_row: @problems_by_row)
			if @problems_by_row.length == 0
				begin
					mis.update_attributes(validation_completion_percent: 50)
					PhysicalObject.transaction do
						@billable.each do |barcode|
							#update_attributes will not throw and exception (the only thing that triggers a rollback in rails) - must use update_attributes!
							po = PhysicalObject.where(mdpi_barcode: barcode).where.not(digital_start: nil).first
							po.update_attributes!(billed: true, spread_sheet_filename: upload.original_filename, date_billed: time)
						end
						mis.update_attributes!(successful_validation: true, validation_completion_percent: 100)
					end
				rescue => error
					mis.update_attributes(other_error: error.to_s << error.backtrace.to_s, successful_validation: false, validation_completion_percent: 100)
				end
			else
				puts "I SHOULD be saving the validation as unsuccessful..."
				mis.update_attributes(successful_validation: false, validation_completion_percent: 100)
			end
		end
	end

	def self.process(upload)
		mis = MemnonInvoiceSubmission.new(filename: upload.original_filename, submission_date: Time.now, successful_validation: false, validation_completion_percent: 0)
		mis.save
		begin
			xlsx = Roo::Excelx.new(upload.tempfile.path, file_warning: :ignore)
			xlsx.default_sheet = xlsx.sheets[0]

			headers = Hash.new
			xlsx.row(1).each_with_index {|header,i|
				headers[header] = i
			}
			# step 1) check for a properly cased header row
			if headers['Object barcode'].nil? or headers['Preservation master File name'].nil?
				mis.update_attributes(successful_validation: false, bad_headers: true, validation_completion_percent: 100)
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

			((xlsx.first_row + 1)..(xlsx.last_row)).each do |row|
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
			@already_billed = PhysicalObject.where("physical_objects.billed = true").joins("INNER JOIN billable_physical_objects ON physical_objects.mdpi_barcode = billable_physical_objects.mdpi_barcode").pluck(:mdpi_barcode, :spread_sheet_filename, :date_billed)

			# step 7) search for any source recording barcodes that are not in the POD - obviously we shouldn't be billed
			# for something that doesn't exist...
			@not_found = BillablePhysicalObject.joins("LEFT JOIN physical_objects ON billable_physical_objects.mdpi_barcode = physical_objects.mdpi_barcode").where("physical_objects.id is null").pluck(:mdpi_barcode)

			# step 8) run query against physical objects that have not started the digitization process - this means they are no
			# on SDA yet, and thus, cannot be billed
			@not_on_sda = PhysicalObject.joins("INNER JOIN billable_physical_objects ON physical_objects.mdpi_barcode = billable_physical_objects.mdpi_barcode").where("digital_start is NULL").pluck(:mdpi_barcode)

			mis.already_billed = @already_billed
			mis.not_found = @not_found
			mis.not_on_sda = @not_on_sda
			mis.preservation_file_copies = @preservation_file_copies

			if @already_billed.size > 0 or @not_found.size > 0 or @not_on_sda.size > 0 or @preservation_file_copies.size > 0
				mis.successful_validation = false
				mis.validation_completion_percent = 100
				mis.save
			else
				begin
					mis.update_attributes(validation_completion_percent: 50)
					PhysicalObject.transaction do
						@billable.each do |barcode|
							#update_attributes will not throw and exception (the only thing that triggers a rollback in rails) - must use update_attributes!
							po = PhysicalObject.where(mdpi_barcode: barcode).where.not(digital_start: nil).first
							po.update_attributes!(billed: true, spread_sheet_filename: upload.original_filename, date_billed: time)
						end
						mis.update_attributes!(successful_validation: true, validation_completion_percent: 100)
					end
				rescue => error
					mis.update_attributes(other_error: error.to_s << error.backtrace.to_s, successful_validation: false, validation_completion_percent: 100)
				end
			end
		rescue => e
			puts e.message
			puts e.backtrace.join("\n")
			mis.update_attributes(other_error: e.message << e.backtrace.join("\n"), successful_validation: false, validation_completion_percent: 100)
		end
	end

end
