class PicklistSpecification < ActiveRecord::Base
	has_many :bins
	serialize :fields
	has_many :technical_metadata

	def init_tm
		if !format.nil?
			if format == "Open Reel Tape"
				tm = OpenReelTm.new
				tm.picklist_specification = self
			end
		end
	end
end
