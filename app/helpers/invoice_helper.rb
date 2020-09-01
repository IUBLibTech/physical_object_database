module InvoiceHelper
	require 'roo'

	def self.logger
		@@logger ||= Logger.new("#{Rails.root}/log/invoice_logger.log", 10, 10.megabytes)
	end

	@@mutex = Mutex.new

	def self.parse_invoice(upload)
		Thread.new {
			@@mutex.synchronize do
				process_rows(upload)
			end
		}
	end

	def self.process_rows(upload)
		if upload.respond_to? :original_filename
			mis = MemnonInvoiceSubmission.new(filename: upload.original_filename, submission_date: Time.now, successful_validation: false, validation_completion_percent: 0)
			mis.save
			if mis.errors.any?
				logger.error "Could not save invoice submission: #{mis.errors.full_messages}"
			else
				logger.unknown "\n\n\n\nProcessing uploaded invoice: #{upload.original_filename}"
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
						logger.unknown "Bad headers..."
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
						logger.unknown "Parsing row #{row}"
						pres_filename = xlsx.row(row)[headers['Preservation master File name']]
						po = PhysicalObject.where(mdpi_barcode: barcode).first
						problem = ""
						problem << "bad barcode [#{barcode}]" if po.nil?
						problem << "missing barcode, " if barcode.blank?
						problem << "missing preservation master filename, " if pres_filename.blank?
						problem << "duplicate preservation master filename, " if @preservation_files.add?(pres_filename).nil?
						unless po.nil?
							problem << "already billed [#{po.spread_sheet_filename}], " if po.billed
						end
						unless po.nil?
							problem << "not on SDA" if po.digital_start.nil?
						end
						if problem.length > 0
							@problems_by_row << "row #{row}: #{problem}" if problem.length > 0
							logger.unknown "Problem with row #{row}: problem: #{problem}"
 						else
							@billable << barcode
						end
					end
		
					mis.update_attributes(problems_by_row: @problems_by_row)
					logger.unknown "Memnon invoice submission updated - total problems: #{@problems_by_row.length}"
					if @problems_by_row.length == 0
						begin
							mis.update_attributes(validation_completion_percent: 50)
							logger.unknown "Updating physical objects..."
							PhysicalObject.transaction do
								@billable.each do |barcode|
									# update_attributes will not throw and exception (the only thing that triggers a rollback in rails) -
									# must use update_attributes!
									po = PhysicalObject.where(mdpi_barcode: barcode).where.not(digital_start: nil).first
									po.update_attributes!(billed: true, spread_sheet_filename: upload.original_filename, date_billed: time)
									logger.unknown "Updated physical object: #{barcode}"
								end
								mis.update_attributes!(successful_validation: true, validation_completion_percent: 100)
								logger.unknown "All physical objects marked as billed."
							end
						rescue => error
							logger.error "An error occurred while marking physical objects as billed - rolling back the transaction..."
							logger.error "Error caused by: #{error.message}"
							logger.error "#{error.backtrace.join("\n")}"
							saved = mis.update_attributes(other_error: error.to_s << error.backtrace.to_s, successful_validation: false, validation_completion_percent: 100)
							logger.error "Memnon Invoice Submission #{saved ? 'was' : 'was not'} saved successfully..."
						end
					else
						saved = mis.update_attributes(successful_validation: false, validation_completion_percent: 100)
						logger.unknown "Validation should be saved as failed... Did it happen? #{saved}"
					end
				end
			end
		else
			logger.error "Invalid upload: #{upload.class.to_s}: #{upload.inspect}"
		end
	end

end
