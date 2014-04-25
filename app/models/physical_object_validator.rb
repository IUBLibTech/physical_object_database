class PhysicalObjectValidator < ActiveModel::Validator

	def validate(po)
		if po.mdpi_barcode != 0 and !ApplicationHelper.valid_barcode?(po.mdpi_barcode)
			po.errors.add :mdpi_barcode, "is not valid!"
		end	
	end

end