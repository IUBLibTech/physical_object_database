class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	has_many :technical_metadata
	has_many :statuses

	def create_tm
		if !format.nil?
			if format == "Open Reel Tape"
				OpenReelTm.new(picklist_specification: self)
			end
		end
	end
end
