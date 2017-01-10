class UmaticVideoTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule

  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,
  })
  TM_FORMAT = ['U-matic']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = [
    "pack_deformation", "recording_standard", "format_duration", "size",
    "tape_stock_brand", "image_format", "format_version"
  ]
  PACK_DEFORMATION_VALUES = hashify ["None", "Minor", "Moderate", "Severe"]
  RECORDING_STANDARD_VALUES = hashify ["NTSC", "PAL", "SECAM", "Unknown"]
  FORMAT_DURATION_VALUES = hashify %w(5 10 15 18 20 30 40 50 60 75 Unknown)
  SIZE_VALUES = hashify ["Large", "Small", "Unknown"]
  IMAGE_FORMAT_VALUES = hashify ["4:3", "16:9", "Unknown"]
  FORMAT_VERSION_VALUES = hashify ["Low Band", "High Band", "SP", "PCM Audio", "Unknown"]

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
    "Size" => :size,
    "Tape stock brand" => :tape_stock_brand,
    "Image format" => :image_format,
    "Format version" => :format_version
  }
  include TechnicalMetadatumModule

  def default_values
    self.recording_standard = "NTSC"
    self.image_format = "4:3"
  end

  def default_values_for_upload
     default_values
     self.pack_deformation = 'None'
     self.format_duration = 'Unknown'
     self.size = 'Unknown'
     self.format_version = 'Unknown'
  end

  def damage
    pack_deformation
  end

  # master_copies default of 1

end
