class TwoInchOpenReelVideoTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  DIGITAL_PROVENANCE_FILES = ['Digital Master', 'PresInt']
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,
  })
  TM_FORMAT = ['2-Inch Open Reel Video Tape']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = %w(recording_standard format_duration reel_type format_version recording_mode tape_stock_brand pack_deformation structural_damage cue_track_contains sound_field)
  RECORDING_STANDARD_VALUES = hashify(%w(NTSC PAL SECAM Unknown))
  FORMAT_DURATION_VALUES = hashify(['90 min', '60 min', '30 min', 'Unknown'])
  REEL_TYPE_VALUES = hashify ['metal reel', 'plastic reel']
  FORMAT_VERSION_VALUES = hashify ['Quadruplex', 'Helical-Ampex', 'Helical-IVC', 'Helical-Sony PV', 'Audio;', 'Octuplex FR data', 'Unknown']
  RECORDING_MODE_VALUES = hashify ['low-band monochrome', 'low-band color', 'high-band', 'super-high-band', 'half-speed', 'unknown']
  PACK_DEFORMATION_VALUES = hashify ['None', 'Minor', 'Moderate', 'Severe']
  CUE_TRACK_CONTAINS_VALUES = hashify ['Audio program', 'Silence', 'Other']
  SOUND_FIELD_VALUES = hashify ['Mono', 'Stereo', 'Unknown']
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = %w(fungus soft_binder_syndrome other_contaminants foam_with_seepage foam_without_seepage)
  MULTIVALUED_FIELDSETS = {
    'Preservation problems' => :PRESERVATION_PROBLEM_FIELDS,
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    'Preservation problems' => 2,
  }
  HUMANIZED_COLUMNS = {
    foam_with_seepage: '3M/Scotch foam-lined flange-with adhesive seepage',
    foam_without_seepage: '3M/Scotch foam-lined flange-no adhesive seepage',
  }
  MANIFEST_EXPORT = {
    "Recording standard" => :recording_standard,
    "Format duration" => :format_duration,
    "Reel type" => :reel_type,
    "Format version" => :format_version,
    "Recording mode" => :recording_mode,
    "Tape stock brand" => :tape_stock_brand,
  }
  include TechnicalMetadatumModule

  def default_values
    self.recording_standard = 'NTSC'
    self.format_duration = 'Unknown'
    self.reel_type = 'metal reel'
    self.format_version = 'Quadruplex'
    self.pack_deformation = 'None'
    self.cue_track_contains = 'Silence'
    self.sound_field = 'Mono'
  end

  def default_values_for_upload
     default_values
  end

  def damage
    pack_deformation
  end

  # master_copies default of 1
end
