class DigitalFileProvenance < ActiveRecord::Base
	belongs_to :digital_provenance

	attr_accessor :display_date_digitized

	def display_date_digitized
		if date_digitized.blank?
			""
		else
			date_digitized.in_time_zone("UTC").strftime("%m/%d/%Y")
		end
	end

	def display_date_digitized=(date)
		unless date.blank?
			self.date_digitized = DateTime.strptime(date, "%m/%d/%Y")
		end
	end
end
