class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	serialize :fields
	has_many :technical_metadata

	def init_tm
		if !format.nil?
			if format == "Open Reel Tape"
				OpenReelTm.new(picklist_specification: self)
			end
		end
	end
end
