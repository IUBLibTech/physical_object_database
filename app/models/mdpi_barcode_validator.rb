class MdpiBarcodeValidator < ActiveModel::EachValidator

	def validate_each(record, attribute, value)
		assigned = ApplicationHelper.barcode_assigned?(value)
		if !ApplicationHelper.valid_barcode?(value)
			record.errors.add(attribute, options[:message] || "is not valid.")
			puts options[:message] || "is not valid."
		elsif (assigned and assigned != record)
			record.errors.add(attribute, options[:message] || error_message_link(record))
			puts options[:message] || error_message_link(record)
		end
	end

	private
		def error_message_link(ob)
			ob.class == Bin.class ?
				"#{ob.mdpi_barcode} has already been assigned to a Bin" :
				ob.class == Box.class ?
					"#{ob.mdpi_barcode} has already been assigned to a Box" :
					"#{ob.mdpi_barcode} has already been assigned to a Physical Object"
		end
end