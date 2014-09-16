class TechnicalMetadatum < ActiveRecord::Base
	acts_as_superclass

	belongs_to :physical_object
	belongs_to :picklist_specification

        #FIXME: add validation that as_technical_metadatum exists?
        validates :as_technical_metadatum, presence: true

	def specialize
	#	Kernel.const_get(self.as_technical_metadatum_type).find(self.as_technical_metadatum_id)
		self.as_technical_metadatum
	end

end
