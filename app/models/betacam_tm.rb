class BetacamTm < ActiveRecord::Base
  acts_as :technical_metadatum
  extend TechnicalMetadatumClassModule
  # TM module constants
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
  FORMAT_DURATION_VALUES = hashify ["", 90, 60, 30, 20, 10, 5 ]
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

  def damage
    pack_deformation
  end

  # master_coipies default of 1

end
