class StagingPercentage < ActiveRecord::Base
	validates :memnon_percent,
		presence: true,
		numericality: { only_integer: true, message: "#%{value} is not a number" },
		inclusion: { in: 0..100, message: "%{value} is not a valid percentage" }
	validates :iu_percent,
		presence: true,
		numericality: { only_integer: true, message: "%{value} is not a number" },
		inclusion: { in: 0..100, message: "%{value} is not a valid percentage" }

	def self.default_percentage
		10
	end
end
