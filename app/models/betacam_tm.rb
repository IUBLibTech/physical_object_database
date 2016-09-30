class BetacamTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  extend TechnicalMetadatumClassModule
  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,
  })
  TM_FORMAT = ['Betacam']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_betacam_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = [
    "format_version", "pack_deformation", "cassette_size",
    "recording_standard", "format_duration", "tape_stock_brand",
    "image_format"
  ]
  FORMAT_VERSION_VALUES = hashify ["", "Oxide", "SP", "SX", "IMX 30", "IMX 40", "IMX 50", "Digital"]
  PACK_DEFORMATION_VALUES = hashify ["", "None", "Minor", "Moderate", "Severe"]
  CASSETTE_SIZE_VALUES = hashify ["", "small", "large"]
  RECORDING_STANDARD_VALUES = hashify ["", "NTSC", "PAL", "SECAM", "Unknown"]
  FORMAT_DURATION_VALUES = hashify ["", 5, 6, 10, 12, 20, 22, 30, 32, 40, 60, 62, 64, 90, 94, 124, 184, 194]
  IMAGE_FORMAT_VALUES = hashify ["", "4:3", "16:9", "Unknown"]
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
    "Year" => :year,
    "Recording standard" => :recording_standard,
    "Image format" => :image_format,
    "Tape stock brand" => :tape_stock_brand,
    "Size" => :cassette_size,
    "Format duration" => :format_duration,
  }
  include TechnicalMetadatumModule
  include YearModule

  # no default_values

  def default_values_for_upload
    self.format_version = ''
    self.pack_deformation = ''
    self.cassette_size = ''
    self.recording_standard = 'Unknown'
    self.format_duration = ''
    self.image_format = 'Unknown'
  end

  def damage
    pack_deformation
  end

  # master_copies default of 1

end
