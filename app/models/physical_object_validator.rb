class PhysicalObjectValidator < ActiveModel::Validator
	
	def validate(record)
		unless 
			(!record.mdpi_barcode.nil? and record.mdpi_barcode > 0) or 
			(!record.iucat_barcode.nil? and record.iucat_barcode > 0) or 
			(!record.title.nil? and record.title.length > 0) or 
			(!record.call_number.nil? and record.call_number.length > 0)
			record.errors[:base] << "In addition to Unit and Format, Physical Objects must have at least one of the following set: MPDI barcode, IUCAT barcode, title, or call number."
		end
	end

end