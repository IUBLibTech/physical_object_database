class OpenReelTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  before_validation :infer_values
  extend TechnicalMetadatumClassModule
  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,

    speed_used: true,
    tape_fluxivity: true,
    volume_units: true,
    analog_output_voltage: true,
    peak: true,
  })

  TM_FORMAT = ['Open Reel Audio Tape']
  TM_SUBTYPE = false
  TM_GENRE = :audio
  TM_PARTIAL = 'show_open_reel_tape_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = ["pack_deformation", "reel_size", "tape_stock_brand", "directions_recorded"]
  PACK_DEFORMATION_VALUES = hashify ["None", "Minor", "Moderate", "Severe"]
  REEL_SIZE_VALUES = hashify ["", "3 in.", "4 in.", "5 in.", "6 in.", "7 in.", "10 in.", "10.5 in."] 
  # TM Boolean fieldsets
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
  SOUND_FIELD_FIELDS = ["mono","dual_mono","stereo","unknown_sound_field"]
  TAPE_BASE_FIELDS = ["acetate_base","polyester_base","pvc_base","paper_base"]
  MULTIVALUED_FIELDSETS = {
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS,
    "Playback speed" => :PLAYBACK_SPEED_FIELDS,
    "Track configuration" => :TRACK_CONFIGURATION_FIELDS,
    "Tape thickness" => :TAPE_THICKNESS_FIELDS,
    "Sound field" => :SOUND_FIELD_FIELDS,
    "Tape base" => :TAPE_BASE_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    "Preservation problems" => 2,
    "Playback speed" => 2,
    "Track configuration" => 2,
    "Tape thickness" => 2,
    "Sound field" => 3,
    "Tape base" => 2
  }
  HUMANIZED_COLUMNS = {:zero_point9375_ips => "0.9375 ips", :one_point875_ips => "1.875 ips", 
    :three_point75_ips => "3.75 ips", :seven_point5_ips => "7.5 ips", :fifteen_ips => "15 ips", 
    :thirty_ips => "30 ips", :unknown_track => "Unknown", :zero_point5_mils => "0.5 mil",
    :one_mils => "1.0 mil", :one_point5_mils => "1.5 mil", :unknown_sound_field => "Unknown", 
    :acetate_base => "Acetate", :polyester_base => "Polyester", :pvc_base => "PVC", :paper_base => "Paper",
    :unknown_playback_speed => "Unknown"
  }
  MANIFEST_EXPORT = {
    "Year" => :year,
    "Tape base" => :TAPE_BASE_FIELDS,
    "Reel size" => :reel_size,
    "Track configuration" => :TRACK_CONFIGURATION_FIELDS,
    "Sound field" => :SOUND_FIELD_FIELDS,
    "Playback speed" => :PLAYBACK_SPEED_FIELDS,
    "Tape thickness" => :TAPE_THICKNESS_FIELDS,
    "Tape stock brand" => :tape_stock_brand,
    "Directions recorded" => :directions_recorded
  }
  include TechnicalMetadatumModule
  include YearModule

  def default_values
    self.pack_deformation ||= "None"
    self.reel_size ||= ""
  end

  def default_values_for_upload
     default_values
  end

  def damage
    pack_deformation
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

  alias_method :reel_sizes, :reel_size_values
  alias_method :pack_deformations, :pack_deformation_values

  def infer_values
    self.calculated_directions_recorded = infer_directions_recorded
    self.directions_recorded ||= self.calculated_directions_recorded
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
