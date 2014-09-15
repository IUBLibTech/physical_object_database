class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	has_one :technical_metadatum, dependent: :destroy
	has_many :statuses
	before_validation :ensure_tm

	validates :name, presence: true, uniqueness: true
	validates :format, inclusion: { in: TechnicalMetadatumModule::TM_FORMATS.keys }
	validates :technical_metadatum, presence: true

	def create_tm
		if TechnicalMetadatumModule::TM_FORMATS[self.format]
			PhysicalObject.new.create_tm(self.format, picklist_specification: self)
		end
	end

	def ensure_tm
		if TechnicalMetadatumModule::TM_FORMATS[self.format]
			if self.technical_metadatum.nil? || self.technical_metadatum.as_technical_metadatum_type != TechnicalMetadatumModule::TM_FORMAT_CLASSES[self.format].to_s
				self.technical_metadatum.destroy unless self.technical_metadatum.nil? 
				@tm = PhysicalObject.new.create_tm(self.format, picklist_specification: self)
                        else
				@tm = self.technical_metadatum.as_technical_metadatum
			end
		end
	end

end
