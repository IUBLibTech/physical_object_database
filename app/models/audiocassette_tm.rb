# Audiocassette format
class AudiocassetteTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    baking: false,

    speed_used: true,
    tape_fluxivity: false,
    volume_units: false,
    analog_output_voltage: false,
    peak: false,
    noise_reduction: true
  })
  TM_FORMAT = ['Audiocassette']
  TM_SUBTYPE = false
  TM_GENRE = :audio
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = true
  BIN_FORMAT = false
  # TM simple fields
  SIMPLE_FIELDS = ['cassette_type', 'tape_type', 'sound_field', 'tape_stock_brand', 'noise_reduction', 'format_duration', 'pack_deformation']
  CASSETTE_TYPE_VALUES = hashify ['Compact', 'Mini', 'Micro']
  TAPE_TYPE_VALUES = hashify ['', 'I', 'II', 'III', 'IV', 'Unknown']
  SOUND_FIELD_VALUES = hashify ['Mono', 'Stereo', 'Unknown']
  NOISE_REDUCTION_VALUES = hashify ['None', 'Dolby B', 'Dolby C', 'Dolby Unknown', 'Unknown']
  PACK_DEFORMATION_VALUES = hashify ['None', 'Minor', 'Moderate', 'Severe']
  # TM Boolean fieldsets
  STRUCTURAL_DAMAGE_FIELDS = ['damaged_tape', 'damaged_shell']
  PLAYBACK_SPEED_FIELDS = [
    'zero_point46875_ips',
    'zero_point9375_ips',
    'one_point875_ips',
    'three_point75_ips',
    'unknown_playback_speed'
  ]
  PRESERVATION_PROBLEM_FIELDS = ['fungus', 'soft_binder_syndrome', 'other_contaminants']
  MULTIVALUED_FIELDSETS = {
    'Preservation problems' => :PRESERVATION_PROBLEM_FIELDS,
    'Structural damage' => :STRUCTURAL_DAMAGE_FIELDS,
    'Playback speed' => :PLAYBACK_SPEED_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    'Preservation problems' => 2,
    'Playback speed' => 2,
    'Structural damage' => 2
  }
  HUMANIZED_COLUMNS = {
    zero_point46875_ips: '0.46875 ips',
    zero_point9375_ips: '0.9375 ips',
    one_point875_ips: '1.875 ips',
    three_point75_ips: '3.75 ips',
    unknown_playback_speed: 'Unknown'
  }
  MANIFEST_EXPORT = {
    'Cassette type' => :cassette_type,
    'Tape type' => :tape_type,
    'Sound field' => :sound_field,
    'Tape stock brand' => :tape_stock_brand,
    'Noise reduction' => :noise_reduction,
    'Format duration' => :format_duration,
    'Structural damage' => :STRUCTURAL_DAMAGE_FIELDS,
    'Playback speed' => :PLAYBACK_SPEED_FIELDS,
  }
  include TechnicalMetadatumModule

  validates :format_duration, presence: true
  validate :playback_speed_validation
  validate :tape_type_validation

  def default_values
    self.cassette_type ||= 'Compact'
    self.tape_type ||= ''
    self.noise_reduction ||= 'None'
    self.pack_deformation ||= 'None'
  end

  def default_values_for_upload
     default_values
     self.sound_field = 'Unknown'
     self.format_duration = 'Unknown'
     self.unknown_playback_speed = true
     self.tape_type = 'Unknown'
  end

  def damage
    pack_deformation
  end

  def master_copies
    2
  end

  def playback_speed_validation
    if PLAYBACK_SPEED_FIELDS.map { |f| self.attributes[f].blank? }.all?
      errors[:base] << 'You must check at least one playback speed; you may check Unknown.'
    end
  end

  def tape_type_validation
    if cassette_type == 'Compact' && tape_type.blank?
      errors[:tape_type] << 'You must specify a Tape type for Compact type audiocassettes.'
    end
  end

end
