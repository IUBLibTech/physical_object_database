class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	has_one :technical_metadatum, dependent: :destroy
	has_many :statuses
	before_validation :ensure_tm

	validates :name, presence: true, uniqueness: true
	def valid_formats
	  TechnicalMetadatumModule.tm_formats_array
	end
	validates :format, inclusion: { in: lambda { |ps| ps.valid_formats } }
	validates :technical_metadatum, presence: true

	def create_tm
		if TechnicalMetadatumModule.tm_formats_hash[self.format]
			PhysicalObject.new.create_tm(self.format, picklist_specification: self)
		end
	end

	def ensure_tm
		if TechnicalMetadatumModule.tm_formats_hash[self.format]
			if self.technical_metadatum.nil? || self.technical_metadatum.as_technical_metadatum_type != TechnicalMetadatumModule.tm_format_classes[self.format].to_s
				@tm = PhysicalObject.new.create_tm(self.format, picklist_specification: self)
                        else
				@tm = self.technical_metadatum.as_technical_metadatum
			end
		end
	end

end
