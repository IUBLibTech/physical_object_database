class OpenReelTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule

	# this hash holds the human reable attribute name for this class
	HUMANIZED_COLUMNS = {:zero_point9375_ips => "0.9375 ips", :one_point875_ips => "1.875 ips", 
		:three_point75_ips => "3.75 ips", :seven_point5_ips => "7.5 ips", :fifteen_ips => "15 ips", 
		:thirty_ips => "30 ips", :unknown_track => "Unknown", :zero_point5_mils => "0.5 mil",
		:one_mils => "1 mil", :one_point5_mils => "1.5 mil", :unknown_sound_field => "Unknown", 
		:acetate_base => "Acetate", :polyester_base => "Polyester", :pvc_base => "PVC", :paper_base => "Paper",
		:unknown_playback_speed => "Unknown", :one_direction => "1", :two_directions => "2", :unknown_direction => "Unknown" 
	}
	PRESERVATION_PROBLEM_FIELDS = ["fungus", "soft_binder_syndrome", "vinegar_syndrome", "other_contaminants"]
	PLAYBACK_SPEED_FIELDS = [
          "zero_point9375_ips",
          "one_point875_ips",
          "three_point75_ips",
          "seven_point5_ips",
          "fifteen_ips",
          "thirty_ips",
          "unknown_playback_speed"
	]
	TRACK_CONFIGURATION_FIELDS = [
	  "full_track", "half_track", "quarter_track", "unknown_track"
	]
	TAPE_THICKNESS_FIELDS = [ "zero_point5_mils", "one_mils", "one_point5_mils" ]
	SOUND_FIELD_FIELDS = ["mono","stereo","unknown_sound_field"]
	TAPE_BASE_FIELDS = ["acetate_base","polyester_base","pvc_base","paper_base"]
	DIRECTIONS_RECORDED_FIELDS = ["one_direction","two_directions","unknown_direction"]

	attr_accessor :reel_sizes
	def reel_sizes
		{"" => "","3 in." => "3 in.", "4 in." => "4 in.", "5 in." => "5 in.", "6 in." => "6 in.", "7 in." => "7 in.", "10 in." => "10 in.", "10.5 in." => "10.5 in."} 
	end

	attr_accessor :pack_deformations
	def pack_deformations
		{"None" => "None", "Minor" => "Minor", "Moderate" => "Moderate", "Severe" => "Severe"}
	end

	attr_accessor :directions_recorded_vals
	def directions_recorded_vals
		{"" => "", "1" => "1", "2" => "2"}
	end

	def damage
	  pack_deformation
	end

	def playback_speed
	  humanize_boolean_fieldset(:PLAYBACK_SPEED_FIELDS)
	end

	def track_configuration
	  humanize_boolean_fieldset(:TRACK_CONFIGURATION_FIELDS)
	end

	def tape_thickness
	  humanize_boolean_fieldset(:TAPE_THICKNESS_FIELDS)
	end

	def sound_field
	  humanize_boolean_fieldset(:SOUND_FIELD_FIELDS)
	end

	def tape_base
	  humanize_boolean_fieldset(:TAPE_BASE_FIELDS)
	end

	def directions_recorded
          humanize_boolean_fieldset(:DIRECTIONS_RECORDED_FIELDS)
	end

end
