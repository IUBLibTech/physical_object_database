class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	has_one :technical_metadatum, dependent: :destroy
	has_many :statuses
	before_validation :ensure_tm

	validates :name, presence: true, uniqueness: true
	def valid_formats
	  TechnicalMetadatumModule::TM_FORMATS_ARRAY
	end
	validates :format, inclusion: { in: lambda { |ps| ps.valid_formats } }
	validates :technical_metadatum, presence: true

	def create_tm
		if TechnicalMetadatumModule::TM_FORMATS_HASH[self.format]
			PhysicalObject.new.create_tm(self.format, picklist_specification: self)
		end
	end

	def ensure_tm
		if TechnicalMetadatumModule::TM_FORMATS_HASH[self.format]
			if self.technical_metadatum.nil? || self.technical_metadatum.as_technical_metadatum_type != TechnicalMetadatumModule::TM_FORMAT_CLASSES[self.format].to_s
				@tm = PhysicalObject.new.create_tm(self.format, picklist_specification: self)
                        else
				@tm = self.technical_metadatum.as_technical_metadatum
			end
		end
	end

end
