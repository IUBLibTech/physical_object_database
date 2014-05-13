class CdrTm < ActiveRecord::Base
	acts_as :technical_metadatum

	# this hash holds the human reable attribute name for this class
	HUMANIZED_COLUMNS = {}

	attr_accessor :damage_values
	def damage_values
		{"None" => "None", "Minor" => "Minor", "Moderate" => "Moderate", "Severe" => "Severe"}
	end

	attr_accessor :format_duration_values
	def format_duration_values
		{"74 min" => "74 min", "80 min" => "80 min", "90 min" => "90 min", "99 min" => "99 min", "Unknown" => "Unknown"}
	end

	def humanize_boolean_fields(*field_names)
  	str = ""
  	field_names.each do |f|
  		str << ((!self[f].nil? and self[f]) ? (str.length > 0 ? ", " << CdrTm.human_attribute_name(f) : CdrTm.human_attribute_name(f)) : "")
  	end
  	str
  end
end
