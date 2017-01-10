class HalfInchOpenReelVideoTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,
  })
  TM_FORMAT = ['1/2-Inch Open Reel Video Tape']
  TM_SUBTYPE = false
  TM_GENRE = :video
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = %w(format_version recording_standard tape_stock_brand format_duration image_format pack_deformation)
  FORMAT_VERSION_VALUES = hashify(%w(EIAJ CV Unknown))
  RECORDING_STANDARD_VALUES = hashify(%w(NTSC PAL SECAM Unknown))
  IMAGE_FORMAT_VALUES = hashify ['4:3', '16:9', 'Unknown']
  PACK_DEFORMATION_VALUES = hashify ['None', 'Minor', 'Moderate', 'Severe']
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = %w(fungus soft_binder_syndrome other_contaminants)
  STRUCTURAL_DAMAGE_FIELDS = %w(damaged_tape damaged_reel)
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
  MANIFEST_EXPORT = {}
  include TechnicalMetadatumModule

  def default_values
    self.format_version = 'Unknown'
    self.recording_standard = 'NTSC'
    self.image_format = '4:3'
    self.pack_deformation = 'None'
  end

  def default_values_for_upload
     default_values
  end

  def damage
    pack_deformation
  end

  # master_copies default of 1

end
