class EightMillimeterVideoTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  extend TechnicalMetadatumClassModule

  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,
  })
  TM_FORMAT = ['8mm Video']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = [
    "pack_deformation", "recording_standard", "format_duration",
    "tape_stock_brand", "image_format", "format_version", "playback_speed",
    "binder_system"
  ]
  PACK_DEFORMATION_VALUES = hashify ["None", "Minor", "Moderate", "Severe"]
  RECORDING_STANDARD_VALUES = hashify ["NTSC", "PAL", "SECAM", "Unknown"]
  IMAGE_FORMAT_VALUES = hashify ["4:3", "16:9", "Unknown"]
  FORMAT_VERSION_VALUES = hashify ["Regular", "Hi", "Digital", "Unknown"]
  PLAYBACK_SPEED_VALUES = hashify ["Standard", "Long Play", "Unknown"]
  BINDER_SYSTEM_VALUES = hashify ["Metal particle", "Metal Evaporated", "Unknown"]

  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = [
    "fungus", "soft_binder_syndrome", "other_contaminants"
  ]
  MULTIVALUED_FIELDSETS = {
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    "Preservation problems" => 2
  }
  HUMANIZED_COLUMNS = {}
  MANIFEST_EXPORT = {
    "Recording standard" => :recording_standard,
    "Format duration" => :format_duration,
    "Tape stock brand" => :tape_stock_brand,
    "Image format" => :image_format,
    "Format version" => :format_version,
    "Playback speed" => :playback_speed,
    "Binder system" => :binder_system
  }
  include TechnicalMetadatumModule

  # no default_values

  def default_values_for_upload
    self.pack_deformation = 'None'
    self.recording_standard = 'Unknown'
    self.image_format = 'Unknown'
    self.format_version = 'Unknown'
    self.playback_speed = 'Unknown'
    self.binder_system = 'Unknown'
  end

  def damage
    pack_deformation
  end

  # master_copies default of 1

end
