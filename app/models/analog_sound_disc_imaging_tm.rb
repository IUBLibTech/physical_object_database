class AnalogSoundDiscImagingTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  DIGITAL_PROVENANCE_FILES = ['Digital Master', 'PresInt', 'Prod', 'Access', 'Miscellaneous']
  PROVENANCE_REQUIREMENTS = TechnicalMetadatumModule::PROVENANCE_REQUIREMENTS.merge({
    speed_used: false,
    volume_units: false,
    stylus_size: false,
    turnover: false,
    rolloff: false,
    rumble_filter: false
  })
  TM_FORMAT = ['Lacquer Disc-imaging']
  TM_SUBTYPE = true
  TM_GENRE = :audio
  TM_PARTIAL = 'show_analog_sound_disc_imaging_tm'
  PRELOAD_PARTIAL = 'preload_generic_tm_fields'
  BOX_FORMAT = true
  BIN_FORMAT = false
  PRELOAD_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = [
    "diameter", "speed", "groove_size", "groove_orientation",
    "recording_method", "material", "substrate", "coating",
    "equalization", "sound_field", "country_of_origin", "label"
  ]
  DIAMETER_VALUES = hashify [5, 6, 7, 8, 9, 10, 12, 16, 'Unknown']
  SPEED_VALUES = hashify [33.3, 45, 78, 'Unknown', 'Mixed']
  GROOVE_SIZE_VALUES = hashify ['Coarse', 'Micro', 'Unknown']
  GROOVE_ORIENTATION_VALUES = hashify ['Lateral', 'Vertical', 'Unknown']
  RECORDING_METHOD_VALUES = hashify ['Pressed', 'Cut', 'Pregrooved', 'Unknown']
  MATERIAL_VALUES = hashify ['Shellac', 'Plastic', 'N/A', 'Unknown']
  SUBSTRATE_VALUES = hashify ["Aluminum", "Glass", "Fiber", "Steel", "Zinc", "N/A", 'Unknown']
  COATING_VALUES = hashify ['None', 'Lacquer', 'N/A', 'Unknown']
  EQUALIZATION_VALUES = hashify ['', 'RIAA', 'ffrr LP 1953', 'CCIR', 'NAB', 'NAB+80Hz', 'FLAT', 'US MID 30', 'WESTREX', 'HMW', 'ffrr 1949', 'Early DECCA', 'COLUMBIA', 'BSI', 'Other', 'Unknown']
  SOUND_FIELD_VALUES = hashify ['Mono', 'Stereo', 'Unknown']
  # (subtype is hidden in form)
  SUBTYPE_VALUES = hashify TM_FORMAT
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = [
    "delamination", "exudation", "oxidation"
  ]
  DAMAGE_FIELDS = [
    "broken", "cracked", "dirty", "fungus", "scratched", "warped", "worn"
  ]
  MULTIVALUED_FIELDSETS = {
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS,
    "Damage" => :DAMAGE_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    "Preservation problems" => 2,
    "Damage" => 2
  }
  HUMANIZED_COLUMNS = {}
  MANIFEST_EXPORT = {
    "Year" => :year,
    "Label" => :label,
    "Diameter in inches" => :diameter,
    "Recording type" => :groove_orientation,
    "Groove type" => :groove_size,
    "Playback speed" => :speed,
    "Equalization" => :equalization
  }
  DEFAULT_VALUES_FOR_PRELOAD = {}
  PRELOAD_CONFIGURATION = {
    sequence: 2,
    text_comments: {
      'Tracking issues are recorded onto disc' => [:pres, :presInt, :prod],
      'Irregularly cut grooves' => [:pres, :presInt, :prod],
      'Overmodulated Grooves' => [:pres, :presInt, :prod],
      'Poor Quality Recording' => [:pres, :presInt, :prod],
      'Delamination around outer edges of disc' => [:pres, :presInt, :prod],
      'Side 02 is blank' => [:pres, :presInt, :prod],
      'Warped' => [:pres, :presInt, :prod],
      'Grooves fall off edge of the disc' => [:pres, :presInt, :prod],
      'Locked Grooves at the end' => [:pres],
      'Grooves on side 2 are unmodulated.' => [:pres, :presInt, :prod],
      'Intermittent wow.' => [:pres, :presInt, :prod],
      'Signal breaks up intermittently.' => [:pres, :presInt, :prod],
      'Disc is at 78 RPM but was played back at 33.3 RPM due to a warp causing tracking errors. File was speed shifted to 78 RPM using time stretching in wavelab with a target stretch factor of 42.593%.' => [:pres, :presInt, :prod],
      'Audio quality is muffled at the beginning due to greater tracking error/tracking distortion near the center of the disc.' => [:pres, :presInt, :prod],
      'Intermittent groove echo.' => [:pres, :presInt, :prod],
      'Speed inconsistencies throughout.' => [:pres, :presInt, :prod],
    }.freeze,
    timestamp_comments: {
      locked_grooves: [:pres],
      speed_fluctuations: [:pres]
    },
    file_uses: {
      default: [:pres, :presInt, :prod, :access, :files],
      optional: []
    },
    uses_attributes: {
      pres: { signal_chain: 'Lacquer Disc-imaging' }.freeze,
      presInt: { signal_chain: 'Lacquer Disc-imaging' }.freeze,
      prod: { signal_chain: 'Lacquer Disc-imaging' }.freeze,
      access: { signal_chain: 'Lacquer Disc-imaging' }.freeze,
      files: { signal_chain: 'Lacquer Disc-imaging' }.freeze
    }.freeze,
    # FIXME: drop support for volume_units?
    # FIXME: find out what "equalization" maps to
    form_attributes: {
      pres: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size}.freeze,
      presInt: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size, turnover: :cylinder_dfp_turnover, rolloff: :cylinder_dfp_rolloff, rumble_filter: :cylinder_dfp_rumble_filter, }.freeze,
      prod: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size, turnover: :cylinder_dfp_turnover, rolloff: :cylinder_dfp_rolloff, rumble_filter: :cylinder_dfp_rumble_filter, }.freeze,
      access: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size, turnover: :cylinder_dfp_turnover, rolloff: :cylinder_dfp_rolloff, rumble_filter: :cylinder_dfp_rumble_filter, }.freeze,
      files: { speed_used: :cylinder_dfp_speed_used, stylus_size: :cylinder_dfp_stylus_size, turnover: :cylinder_dfp_turnover, rolloff: :cylinder_dfp_rolloff, rumble_filter: :cylinder_dfp_rumble_filter, }.freeze
    }.freeze,
    tm_attributes: {}
  }
  include TechnicalMetadatumModule
  include YearModule

  #NOTE: default values must be string values
  DEFAULT_VALUES = {
    "Lacquer Disc-imaging" => { diameter: nil,
      speed: nil,
      groove_size: nil,
      groove_orientation: "Lateral",
      sound_field: "Mono",
      recording_method: "Cut",
      substrate: "Aluminum",
      coating: "Lacquer",
      material: "N/A",
      equalization: "Other"
    },
  }

  def default_values(subtype_set = nil)
    subtype_set ||= subtype
    values_hash = DEFAULT_VALUES[subtype_set]
    values_hash&.each do |k,v|
      self.send("#{k}=", v) if self.send(k).nil?
    end
  end

  def default_values_for_upload
     default_values('Lacquer Disc-imaging')
  end

  def damage
    humanize_boolean_fieldset(:DAMAGE_FIELDS)
  end

  def master_copies
    2
  end

end
