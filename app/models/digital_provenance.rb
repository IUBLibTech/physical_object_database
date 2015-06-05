class DigitalProvenance < ActiveRecord::Base
	extend TechnicalMetadatumClassModule #extended to grab the hashify method
	belongs_to :physical_object

	DIGITIZING_ENTITY_VALUES = hashify(["IU","Memnon Archiving Service"])

	def digitizing_entity_values
		DIGITIZING_ENTITY_VALUES
	end

end
