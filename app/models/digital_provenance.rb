class DigitalProvenance < ActiveRecord::Base
	belongs_to :physical_object
	has_many :digital_file_provenances
	accepts_nested_attributes_for :digital_file_provenances, allow_destroy: true

	IU_DIGITIZING_ENTITY = "IU Media Digitization Studios"
	MEMNON_DIGITIZING_ENTITY = "Memnon Archiving Services Inc"
	DIGITIZING_ENTITY_VALUES = {
	  "IU Media Digitization Studios" => "IU Media Digitization Studios",
	  "Memnon Archiving Services Inc" => "Memnon Archiving Services Inc" }
	validates :physical_object, presence: true
	#validates :digitizing_entity, presence: true, inclusion: { in: DIGITIZING_ENTITY_VALUES.keys }
	#validates :duration, presence: true

	def digitizing_entity_values
		DIGITIZING_ENTITY_VALUES
	end

end
