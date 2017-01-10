class VhsTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  validates :format_duration, presence: true
  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,
  })
  TM_FORMAT = ['VHS']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = %w(format_version recording_standard tape_stock_brand format_duration playback_speed size image_format pack_deformation)
  FORMAT_VERSION_VALUES = hashify(['VHS', 'SVHS', 'Unknown'])
  RECORDING_STANDARD_VALUES = hashify(%w(NTSC PAL SECAM Unknown))
  PLAYBACK_SPEED_VALUES = hashify(['Standard Play', 'Long Play', 'Extended Play', 'Unknown'])
  SIZE_VALUES = hashify(%w(Standard Small))
  IMAGE_FORMAT_VALUES = hashify ['4:3', '16:9', 'Unknown']
  PACK_DEFORMATION_VALUES = hashify ['None', 'Minor', 'Moderate', 'Severe']
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = %w(fungus soft_binder_syndrome other_contaminants)
  STRUCTURAL_DAMAGE_FIELDS = %w(damaged_tape damaged_shell)
  MULTIVALUED_FIELDSETS = {
    'Preservation problems' => :PRESERVATION_PROBLEM_FIELDS,
    'Structural damage' => :STRUCTURAL_DAMAGE_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    'Preservation problems' => 2,
    'Structural Damage' => 2
  }
  HUMANIZED_COLUMNS = {}
  MANIFEST_EXPORT = {
    'Format version' => :format_version,
    'Recording standard' => :recording_standard,
    'Format duration' => :format_duration,
    'Playback speed' => :playback_speed
  }
  include TechnicalMetadatumModule

  def default_values
    self.format_version = 'Unknown'
    self.recording_standard = 'NTSC'
    self.playback_speed = 'Unknown'
    self.size = 'Standard'
    self.image_format = '4:3'
    self.pack_deformation = 'None'
  end

  def default_values_for_upload
     default_values
     self.format_duration = 'Unknown'
  end

  def damage
    pack_deformation
  end

  # master_copies default of 1

end
