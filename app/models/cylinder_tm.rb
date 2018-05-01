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
  PRELOAD_PARTIAL = 'preload_generic_tm_fields'
  BOX_FORMAT = false
  BIN_FORMAT = true
  PRELOAD_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = ["size", "material", "groove_pitch", "playback_speed", "recording_method"]
  SIZE_VALUES = hashify ["Standard", "Concert", "Six inch", "Unknown"]
  MATERIAL_VALUES = hashify ["Wax", "Celluloid", "Unknown"]
  GROOVE_PITCH_VALUES = hashify ["100 tpi", "200 tpi", "Other", "Unknown"]
  RECORDING_METHOD_VALUES = hashify ["Cut", "Molded", "Unknown"]
  # TM Boolean fieldsets
  STRUCTURAL_DAMAGE_FIELDS = ["fragmented", "repaired_break", "cracked", "damaged_core", "out_of_round"]
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
  DEFAULT_VALUES_FOR_PRELOAD = {
    size: 'Standard',
    material: 'Wax',
    groove_pitch: '100 tpi',
    recording_method: 'Cut'
  }.freeze
  PRELOAD_CONFIGURATION = {
    sequence: 1,
    text_comments: {
      'Undersampled at 48kHz' => [:pres, :presInt, :prod],
      'Overmodulated grooves' => [:pres, :presInt, :prod],
      'Grooves cut into the edge of cylinder' => [:pres, :presInt, :prod],
      'Captured in reverse' => [:pres, :presInt, :prod],
      'Groove echo' => [:pres, :presInt, :prod],
      'Low level mechanical noise' => [:pres, :presInt, :prod],
      'Irregularly cut grooves' => [:pres, :presInt, :prod],
      'Extremely low level content' => [:pres, :presInt, :prod],
      'No discernible content' => [:pres, :presInt, :prod],
      'Partial transfer' => [:pres, :presInt, :prod],
      'Locked grooves at the end' => [:pres, :presInt, :prod],
      'False start at the beginning' => [:pres, :presInt, :prod]
    }.freeze,
    text_comment_uses: [:pres, :presInt, :prod].freeze,
    timestamp_comments: {
      :locked_grooves => [:pres, :presInt, :prod],
      :speed_change => [:pres, :presInt, :prod],
      :speed_fluctuations => [:pres, :presInt, :prod],
      :second_attempt => [:pres, :presInt, :prod]
    }.freeze,
    timestamp_comment_uses: [:pres].freeze,
    file_uses: {
      default: [:pres, :presRef, :presInt, :intRef, :prod],
      optional: []
    },
    uses_attributes: {
      pres: { reference_tone_frequency: nil, speed_used: nil, stylus_size: nil, comment: '', signal_chain: 'Cylinder audio'},
      presRef: { reference_tone_frequency: 440, speed_used: 'N/A', stylus_size: 'N/A', comment: nil, signal_chain: 'Cylinder refTone'},
      presInt: { reference_tone_frequency: nil, speed_used: nil, stylus_size: nil, comment: '', signal_chain: 'Cylinder audio'},
      intRef: { reference_tone_frequency: 440, speed_used: 'N/A', stylus_size: 'N/A', comment: nil, signal_chain: 'Cylinder refTone'},
      prod: { reference_tone_frequency: nil, speed_used: nil, stylus_size: nil, comment: 'De-click, De-crackle, normalized to -7 dBfs. Then Spectral De-noise, EQ, normalized to -7 dBfs again.', signal_chain: 'Cylinder audio'}
    }.freeze,
    form_attributes: {
      pres: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size}.freeze,
      presRef: {}.freeze,
      presInt: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size}.freeze,
      intRef: {}.freeze,
      prod: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size}.freeze,
    }.freeze,
    tm_attributes: {
      playback_speed: :cylinder_dfp_speed_used
    }.freeze
  }.freeze
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
