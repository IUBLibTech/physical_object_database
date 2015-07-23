class OpenReelTm < ActiveRecord::Base
	acts_as :technical_metadatum
	after_initialize :default_values, if: :new_record?
        before_validation :infer_values
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule
	include YearModule

	# this hash holds the human reable attribute name for this class
	HUMANIZED_COLUMNS = {:zero_point9375_ips => "0.9375 ips", :one_point875_ips => "1.875 ips", 
		:three_point75_ips => "3.75 ips", :seven_point5_ips => "7.5 ips", :fifteen_ips => "15 ips", 
		:thirty_ips => "30 ips", :unknown_track => "Unknown", :zero_point5_mils => "0.5 mil",
		:one_mils => "1.0 mil", :one_point5_mils => "1.5 mil", :unknown_sound_field => "Unknown", 
		:acetate_base => "Acetate", :polyester_base => "Polyester", :pvc_base => "PVC", :paper_base => "Paper",
		:unknown_playback_speed => "Unknown"
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

	REEL_SIZE_VALUES = hashify ["", "3 in.", "4 in.", "5 in.", "6 in.", "7 in.", "10 in.", "10.5 in."] 
	PACK_DEFORMATION_VALUES = hashify ["None", "Minor", "Moderate", "Severe"]
	SIMPLE_FIELDS = ["pack_deformation", "reel_size", "tape_stock_brand", "directions_recorded"]
	SELECT_VALUES = {
	  "pack_deformation" => PACK_DEFORMATION_VALUES,
	  "reel_size" => REEL_SIZE_VALUES
	}
	MULTIVALUED_FIELDSETS = {
	  "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS,
	  "Playback speed" => :PLAYBACK_SPEED_FIELDS,
	  "Track configuration" => :TRACK_CONFIGURATION_FIELDS,
	  "Tape thickness" => :TAPE_THICKNESS_FIELDS,
	  "Sound field" => :SOUND_FIELD_FIELDS,
	  "Tape base" => :TAPE_BASE_FIELDS
	}
	FIELDSET_COLUMNS = {
	  "Preservation problems" => 2,
	  "Playback speed" => 2,
	  "Track configuration" => 2,
	  "Tape thickness" => 2,
	  "Sound field" => 3,
	  "Tape base" => 2
	}
        MANIFEST_EXPORT = {
          "Year" => :year,
          "Tape base" => :TAPE_BASE_FIELDS,
          "Reel size" => :reel_size,
          "Track configuration" => :TRACK_CONFIGURATION_FIELDS,
          "Sound field" => :SOUND_FIELD_FIELDS,
          "Playback speed" => :PLAYBACK_SPEEDd_FIELDS,
          "Tape thickness" => :TAPE_THICKNESS_FIELDS,
          "Tape stock brand" => :tape_stock_brand,
          "Directions recorded" => :directions_recorded
        }

	validates :pack_deformation, inclusion: { in: PACK_DEFORMATION_VALUES.keys }
	validates :reel_size, inclusion: { in: REEL_SIZE_VALUES.keys }

	attr_accessor :reel_sizes
	def reel_sizes
	  REEL_SIZE_VALUES
	end

	attr_accessor :pack_deformations
	def pack_deformations
	  PACK_DEFORMATION_VALUES
	end

	def default_values
	  self.pack_deformation ||= "None"
	  self.reel_size ||= "Unknown"
	end

	def infer_values
	  self.directions_recorded = infer_directions_recorded
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

	# Note that the checked traits are not mutually exclusive, so the biggest number wins
	def master_copies
        	if self.unknown_track
			4
		elsif self.quarter_track
			if stereo and not mono and not unknown_sound_field
				2
			else
				4
			end
		elsif self.half_track
			if stereo and not mono and not unknown_sound_field
				1
			else
				2
			end
		elsif self.full_track
			1
		else
			# if no track specification selected, as per Unknown
			4
		end
	end

	def infer_directions_recorded
	  if self.unknown_track || self.quarter_track
	    2
	  elsif self.half_track
	    if self.stereo && !self.mono && !self.unknown_sound_field
	      1
	    else
	      2
	    end
	  elsif self.full_track
	    1
	  else
	    2
	  end
	end

end
