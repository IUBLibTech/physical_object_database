class DigitalProvenance < ActiveRecord::Base
	belongs_to :physical_object
	has_many :digital_file_provenances
	accepts_nested_attributes_for :digital_file_provenances, allow_destroy: true

	IU_DIGITIZING_ENTITY = "IU Media Digitization Studios"
	MEMNON_DIGITIZING_ENTITY = "Memnon Archiving Services Inc"
	DIGITIZING_ENTITY_VALUES = {
	  IU_DIGITIZING_ENTITY => IU_DIGITIZING_ENTITY,
	  MEMNON_DIGITIZING_ENTITY => MEMNON_DIGITIZING_ENTITY }
	validates :physical_object, presence: true
	#validates :digitizing_entity, presence: true, inclusion: { in: DIGITIZING_ENTITY_VALUES.keys }
	#validates :duration, presence: true

	def digitizing_entity_values
		DIGITIZING_ENTITY_VALUES
	end

  def complete?
    complete = true
    if self.physical_object && self.physical_object.ensure_tm
      self.attributes.keys.map { |a| a.to_sym }.select { |a| !a.in? [:id] }.each do |att|
        if self[att].blank? && self.physical_object.ensure_tm.provenance_requirements[att]
          complete = false
          break
        end
      end
    end
    complete
  end

end
