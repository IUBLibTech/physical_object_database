class CdrTm < ActiveRecord::Base
	acts_as :technical_metadatum
	after_initialize :default_values
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule

	# this hash holds the human readable attribute name for this class
	HUMANIZED_COLUMNS = {}
	PRESERVATION_PROBLEM_FIELDS = ["breakdown_of_materials", "fungus", "other_contaminants"]
	DAMAGE_VALUES = hashify ["None", "Minor", "Moderate", "Severe"]
	FORMAT_DURATION_VALUES = hashify ["", "74 min", "80 min", "90 min", "99 min", "Unknown"]
	SIMPLE_FIELDS = ["damage", "format_duration"]
	MULTIVALUED_FIELDSETS = {
		"Preservation problems" => :PRESERVATION_PROBLEM_FIELDS
	}

	validates :damage, inclusion: { in: DAMAGE_VALUES.keys }
	validates :format_duration, inclusion: { in: FORMAT_DURATION_VALUES.keys }

	attr_accessor :damage_values
	def damage_values
	  DAMAGE_VALUES
	end

	attr_accessor :format_duration_values
	def format_duration_values
	  FORMAT_DURATION_VALUES
	end

	def default_values
	  self.damage ||= "None"
	  self.format_duration ||= ""
	end
end
