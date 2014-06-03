class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	has_one :technical_metadatum
	has_many :statuses

	def create_tm
		if !format.nil?
			if format == "Open Reel Audio Tape"
				OpenReelTm.new(picklist_specification: self)
			elsif format == "CD-R"
				CdrTm.new(picklist_specification: self)
			elsif format == "DAT"
				DatTm.new(picklist_specification: self)
			else
				raise "Unknown format #{format}"
			end
		end
	end
end
