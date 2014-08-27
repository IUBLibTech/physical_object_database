class CdrTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule

	# this hash holds the human readable attribute name for this class
	HUMANIZED_COLUMNS = {}

	attr_accessor :damage_values
	def damage_values
		{"None" => "None", "Minor" => "Minor", "Moderate" => "Moderate", "Severe" => "Severe"}
	end

	attr_accessor :format_duration_values
	def format_duration_values
		{"" => "", "74 min" => "74 min", "80 min" => "80 min", "90 min" => "90 min", "99 min" => "99 min", "Unknown" => "Unknown"}
	end

end
