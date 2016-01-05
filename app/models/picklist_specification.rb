class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	has_one :technical_metadatum, dependent: :destroy, validate: true
	has_many :statuses
	before_validation :ensure_tm

	validates :name, presence: true, uniqueness: true
	def valid_formats
	  TechnicalMetadatumModule.tm_formats_array
	end
	validates :format, inclusion: { in: lambda { |ps| ps.valid_formats } }
	validates :technical_metadatum, presence: true
	accepts_nested_attributes_for :technical_metadatum

	def create_tm
		if TechnicalMetadatumModule.tm_formats_hash[self.format]
			PhysicalObject.new.create_tm(self.format, picklist_specification: self)
		end
	end

	def ensure_tm
		if TechnicalMetadatumModule.tm_formats_hash[self.format]
			if self.technical_metadatum.nil? || self.technical_metadatum.specific.nil? ||self.technical_metadatum.actable_type != TechnicalMetadatumModule.tm_format_classes[self.format].to_s
				@tm = PhysicalObject.new.create_tm(self.format, picklist_specification: self)
        #checks to ensure correct child/parent linkage for new objects; gem does not seem to take care of this?
        self.technical_metadatum = @tm.technical_metadatum if self.technical_metadatum != @tm.technical_metadatum
        self.technical_metadatum.actable = @tm if self.technical_metadatum.actable != @tm
        @tm
                        else
				@tm = self.technical_metadatum.specific
			end
		end
	end

end
