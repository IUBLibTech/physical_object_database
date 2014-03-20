class TechnicalMetadatum < ActiveRecord::Base
	acts_as_superclass

	belongs_to :physical_object
	belongs_to :picklist_specification

	def specialize
		Kernel.const_get(self.as_technical_metadatum_type).find(self.as_technical_metadatum_id)
	end

end
