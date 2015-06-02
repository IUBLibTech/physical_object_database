class PhysicalObjectValidator < ActiveModel::Validator
	include TechnicalMetadatumModule
	def validate(record)
		# piggy back on the validation to set audio/video media type - not the optimal place for this but setting a
		# before_validation in physical object was creating an intermittent bug...
		if TM_GENRES[record.format] == :audio
      record.audio = true
      record.video = nil
    elsif TM_GENRES[record.format] == :video
      record.audio = nil
      record.video = true
    end
    
		unless 
			(!record.mdpi_barcode.nil? and record.mdpi_barcode > 0) or 
			(!record.iucat_barcode.nil? and record.iucat_barcode.to_s.length > 0) or 
			(!record.title.nil? and record.title.length > 0) or 
			(!record.call_number.nil? and record.call_number.length > 0)
			record.errors[:base] << "In addition to Unit and Format, Physical Objects must have at least one of the following set: MPDI barcode, IUCAT barcode, title, or call number."
		end
	end

end
