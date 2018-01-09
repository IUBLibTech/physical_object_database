class DvdTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['DVD']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = true
  BIN_FORMAT = false
  # TM simple fields
  SIMPLE_FIELDS = ['recording_standard', 'format_duration', 'image_format', 'dvd_type', 'stock_brand', 'damage']
  RECORDING_STANDARD_VALUES = hashify ['NTSC', 'PAL', 'SECAM', 'Unknown']
  FORMAT_DURATION_VALUES = hashify ['120 min', '240 min', 'Unknown']
  IMAGE_FORMAT_VALUES = hashify ['4:3', '16:9', 'Unknown']
  DVD_TYPE_VALUES = hashify ['Pressed DVD', 'DVD±R', 'DVD±RW'] 
  DAMAGE_VALUES = hashify ["None", "Minor", "Moderate", "Severe"]
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = ["breakdown_of_materials", "fungus", "other_contaminants"]
  MULTIVALUED_FIELDSETS = {
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    "Preservation problems" => 2
  }
  HUMANIZED_COLUMNS = { :dvd_type => 'DVD type' }
  MANIFEST_EXPORT = {
    'Recording standard' => :recording_standard,
    'Format duration' => :format_duration,
    'Image format' => :image_format,
    'DVD type' => :dvd_type,
    'Stock brand' => :stock_brand,
  }  
  include TechnicalMetadatumModule

  def default_values
    self.recording_standard ||= 'NTSC'
    self.format_duration ||= 'Unknown'
    self.image_format ||= 'Unknown'
    self.dvd_type = 'DVD±R'
    self.damage ||= 'None'
  end

  def default_values_for_upload
     default_values
  end

  # damage field

  # master_copies default of 1
end
