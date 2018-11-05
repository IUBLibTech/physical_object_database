class DvTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  DIGITAL_PROVENANCE_FILES = ['Digital Master', 'PresInt']
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['DV']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = true
  BIN_FORMAT = false
  # TM simple fields
  SIMPLE_FIELDS = %w(recording_standard format_duration image_format variant size stock_brand damage playback_speed)
  RECORDING_STANDARD_VALUES = hashify(%w[NTSC PAL SECAM Unknown])
  FORMAT_DURATION_VALUES = hashify(['60 min', '63 min', '80 min', '83 min', 'Unknown', '12 min', '22 min', '24 min', '30 min', '32 min', '33 min', '34 min', '40 min', '64 min', '66 min', '94 min', '124 min', '126 min', '184 min', '276 min'])
  IMAGE_FORMAT_VALUES = hashify(['4:3', '16:9', 'Unknown'])
  VARIANT_VALUES = hashify(['DV', 'DVCAM', 'HDV', 'DVCPRO', 'DVCPRO50', 'DVCPRO HD', 'Unknown'])
  SIZE_VALUES = hashify(%w[Small Medium Large XL])
  DAMAGE_VALUES = hashify(%w[None Minor Moderate Severe])
  PLAYBACK_SPEED_VALUES = hashify(['Standard Play', 'Long Play', 'Unknown'])
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = %w(breakdown_of_materials fungus other_contaminants)
  MULTIVALUED_FIELDSETS = {
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    'Preservation problems' => 2,
  }
  HUMANIZED_COLUMNS = {}
  MANIFEST_EXPORT = {
    'Recording standard' => :recording_standard,
    'Format duration' => :format_duration,
    'Image format' => :image_format,
    'Variant' => :variant,
    'Size' => :size,
    'Stock brand' => :stock_brand,
    'Playback speed' => :playback_speed
  }
  include TechnicalMetadatumModule

  def default_values
    self.recording_standard = 'NTSC'
    self.format_duration = 'Unknown'
    self.image_format = 'Unknown'
    self.variant = 'Unknown'
    self.size = 'Small'
    self.damage = 'None'
    self.playback_speed = 'Unknown'
  end

  def default_values_for_upload
    default_values
  end

  # damage field

  # master_copies default of 1
end
