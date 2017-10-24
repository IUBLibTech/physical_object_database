class CylinderTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    speed_used: false,
    volume_units: false,
    stylus_size: false,
    turnover: nil,
    rolloff: nil,
    rumble_filter: nil,
    reference_tone_frequency: false,
  }) 
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['Cylinder']
  TM_SUBTYPE = false
  TM_GENRE = :audio
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = ["size", "material", "groove_pitch", "playback_speed", "recording_method"]
  SIZE_VALUES = hashify ["Standard", "Concert", "Six inch", "Unknown"]
  MATERIAL_VALUES = hashify ["Wax", "Celluloid", "Unknown"]
  GROOVE_PITCH_VALUES = hashify ["100 tpi", "200 tpi", "Other", "Unknown"]
  RECORDING_METHOD_VALUES = hashify ["Cut", "Molded", "Unknown"]
  # TM Boolean fieldsets
  STRUCTURAL_DAMAGE_FIELDS = ["fragmented", "repaired_break", "cracked", "damaged_core"]
  PRESERVATION_PROBLEM_FIELDS = ["fungus", "efflorescence", "other_contaminants"]
  MULTIVALUED_FIELDSETS = {
    "Structural Damage" => :STRUCTURAL_DAMAGE_FIELDS,
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    "Preservation problems" => 2
  }
  HUMANIZED_COLUMNS = {}
  MANIFEST_EXPORT = {}
  include TechnicalMetadatumModule

  def default_values
    self.size ||= "Unknown"
    self.material ||= "Unknown"
    self.groove_pitch ||= "Unknown"
    self.recording_method ||= "Unknown"
  end

  def default_values_for_upload
    default_values
  end

  def damage
    structural_damage
  end

  # master_copies default of 1
end
