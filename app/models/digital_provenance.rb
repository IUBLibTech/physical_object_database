class DigitalProvenance < ActiveRecord::Base
	extend TechnicalMetadatumClassModule #extended to grab the hashify method
	belongs_to :physical_object
	has_many :digital_file_provenances
	accepts_nested_attributes_for :digital_file_provenances, allow_destroy: true

	DIGITIZING_ENTITY_VALUES = hashify(["IU Media Digitization Studios","Memnon Archiving Service"])

	def digitizing_entity_values
		DIGITIZING_ENTITY_VALUES
	end

end
