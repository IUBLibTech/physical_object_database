class MdpiBarcodeValidator < ActiveModel::EachValidator

	def validate_each(record, attribute, value)
		assigned = ApplicationHelper.barcode_assigned?(value)
		if !ApplicationHelper.valid_barcode?(value)
			record.errors.add(attribute, options[:message] || "is not valid.")
			puts options[:message] || "is not valid."
		elsif (assigned and assigned != record)
			record.errors.add(attribute, options[:message] || error_message_link(assigned))
			puts options[:message] || error_message_link(record)
		end
	end

	private
		def error_message_link(assigned)
			assigned.class == Bin ?
				"#{assigned.mdpi_barcode} has already been assigned to a Bin" :
				assigned.class == Box ?
					"#{assigned.mdpi_barcode} has already been assigned to a Box" :
					"#{assigned.mdpi_barcode} has already been assigned to a Physical Object"
		end
end