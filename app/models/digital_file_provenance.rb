class DigitalFileProvenance < ActiveRecord::Base
	after_initialize :default_values, if: :new_record?
	belongs_to :digital_provenance
	belongs_to :signal_chain

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

	def default_values
		self.created_by ||= User.current_user
		self.date_digitized ||= Time.now
	end
end
