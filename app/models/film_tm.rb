class FilmTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['Film']
  TM_SUBTYPE = false
  TM_GENRE = :film
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = ['gauge', 'footage', 'frame_rate', 'sound', 'clean', 'resolution', 'color_space', 'workflow', 'on_demand', 'return_on_original_reel', 'brittle', 'broken', 'channeling', 'color_fade', 'cue_marks', 'dirty', 'edge_damage', 'holes', 'peeling', 'perforation_damage', 'rusty', 'scratches', 'soundtrack_damage', 'splice_damage', 'stains', 'sticky', 'tape_residue', 'tearing', 'warp', 'water_damage', 'mold', 'shrinkage', 'ad_strip', 'missing_footage', 'miscellaneous', 'return_to', 'anamorphic', 'track_count', 'format_duration', 'conservation_actions']
  ANAMORPHIC_VALUES = hashify ['', 'Yes', 'No']
  # FIXME: add values list for color_space
  GAUGE_VALUES = hashify ['8mm', 'Super 8mm', '9.5mm', '16mm', 'Super 16mm', '28mm', '35mm', '35/32mm', '70mm']
  FRAME_RATE_VALUES = hashify ['', '16 fps', '18 fps', '24 fps']
  SOUND_VALUES = hashify ['', 'Sound', 'Silent']
  CLEAN_VALUES = hashify ['', 'Yes', 'No', 'Hand clean only']
  RESOLUTION_VALUES = hashify ['', '2k', '4k', '5k', 'HD', 'Audio only']
  WORKFLOW_VALUES = hashify ['', '1', '2', 'evaluate']
  ON_DEMAND_VALUES = hashify ['', 'Yes', 'No']
  RETURN_ON_ORIGINAL_REEL_VALUES = hashify ['', 'Yes', 'No']
  MOLD_VALUES = hashify ['', 'Yes', 'No', 'Treated']
  AD_STRIP_VALUES = hashify ['', '0.0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0']
  TRACK_COUNT_VALUES = hashify ['', '1', '2', '3', '4', '5', '6']
  CONDITION_RATINGS = hashify ['0', '1', '2', '3', '4']
  BRITTLE_VALUES = CONDITION_RATINGS
  BROKEN_VALUES = CONDITION_RATINGS
  CHANNELING_VALUES = CONDITION_RATINGS
  COLOR_FADE_VALUES = CONDITION_RATINGS
  CUE_MARKS_VALUES = CONDITION_RATINGS
  DIRTY_VALUES = CONDITION_RATINGS
  EDGE_DAMAGE_VALUES = CONDITION_RATINGS
  HOLES_VALUES = CONDITION_RATINGS
  PEELING_VALUES = CONDITION_RATINGS
  PERFORATION_DAMAGE_VALUES = CONDITION_RATINGS
  RUSTY_VALUES = CONDITION_RATINGS
  SCRATCHES_VALUES = CONDITION_RATINGS
  SOUNDTRACK_DAMAGE_VALUES = CONDITION_RATINGS
  SPLICE_DAMAGE_VALUES = CONDITION_RATINGS
  STAINS_VALUES = CONDITION_RATINGS
  STICKY_VALUES = CONDITION_RATINGS
  TAPE_RESIDUE_VALUES = CONDITION_RATINGS
  TEARING_VALUES = CONDITION_RATINGS
  WARP_VALUES = CONDITION_RATINGS
  WATER_DAMAGE_VALUES = CONDITION_RATINGS

  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = ['poor_wind', 'not_on_core_or_reel', 'lacquer_treated', 'replasticized', 'dusty', 'spoking']
  FILM_GENERATION_FIELDS = ['projection_print', 'a_roll', 'b_roll', 'c_roll', 'd_roll', 'answer_print', 'camera_original', 'composite', 'duplicate', 'edited', 'fine_grain_master', 'intermediate', 'kinescope', 'magnetic_track', 'master', 'mezzanine', 'negative', 'optical_sound_track', 'original', 'outs_and_trims', 'positive', 'reversal', 'work_print', 'separation_master']
  BASE_FIELDS = ['acetate', 'polyester', 'nitrate', 'mixed']
  COLOR_FIELDS = ['bw', 'toned', 'tinted', 'hand_coloring', 'stencil_coloring', 'color', 'ektachrome', 'kodachrome', 'technicolor', 'anscochrome', 'eco', 'eastman']
  ASPECT_RATIO_FIELDS = ['one_point33', 'one_point37', 'one_point66', 'one_point85', 'two_point35', 'two_point39', 'two_point59', 'two_point66']
  SOUND_FIELD_FIELDS = ['sound_mono', 'sound_stereo', 'sound_surround', 'sound_multi_track', 'sound_dual']
  SOUND_FORMAT_TYPE_FIELDS = ['optical', 'optical_variable_area', 'optical_variable_density', 'magnetic', 'digital_sdds', 'digital_dts', 'digital_dolby_digital', 'sound_on_separate_media']
  SOUND_CONTENT_TYPE_FIELDS = ['music_track', 'effects_track', 'composite_track', 'dialog', 'outtakes']
  STOCK_FIELDS = ['stock_agfa', 'stock_ansco', 'stock_dupont', 'stock_orwo', 'stock_fuji', 'stock_gevaert', 'stock_kodak', 'stock_ferrania', 'stock_three_m', 'stock_agfa_gevaert', 'stock_pathe', 'stock_unknown']
  MULTIVALUED_FIELDSETS = {
    'Film generation' => :FILM_GENERATION_FIELDS,
    'Base' => :BASE_FIELDS,
    'Color' => :COLOR_FIELDS,
    'Aspect ratio' => :ASPECT_RATIO_FIELDS,
    'Sound field' => :SOUND_FIELD_FIELDS,
    'Sound format type' => :SOUND_FORMAT_TYPE_FIELDS,
    'Sound content type' => :SOUND_CONTENT_TYPE_FIELDS,
    'Preservation problems' => :PRESERVATION_PROBLEM_FIELDS,
    'Stock' => :STOCK_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    'Film generation' => 3,
    'Base' => 3,
    'Color' => 3,
    'Aspect ratio' => 3,
    'Sound format type' => 3,
    'Preservation problem fields' => 3
  }
  HUMANIZED_COLUMNS = {
    one_point33: '1.33:1',
    one_point37: '1.37:1',
    one_point66: '1.66:1',
    one_point85: '1.85:1',
    two_point35: '2.35:1',
    two_point39: '2.39:1',
    two_point59: '2.59:1',
    two_point66: '2.66:1',
    sound_mono: 'Mono',
    sound_stereo: 'Stereo',
    sound_surround: 'Surround',
    sound_multi_track: 'Multi-track (i.e. Maurer)',
    sound_dual: 'Dual mono',
    optical_sound_track: 'Optical soundtrack',
    bw: 'Black and white',
    optical_variable_area: 'Optical: variable area',
    optical_variable_density: 'Optical: variable density',
    digital_sdds: 'Digital: SDDS',
    digital_dts: 'Digital: DTS',
    digital_dolby_digital: 'Digital: Dolby Digital',
    digital_dolby_a: 'Digital: Dolby A',
    digital_dolby_sr: 'Digital: Dolby SR',
    stock_agfa: 'Agfa',
    stock_ansco: 'Ansco',
    stock_dupont: 'Dupont',
    stock_orwo: 'Orwo',
    stock_fuji: 'Fuji',
    stock_gevaert: 'Gevaert',
    stock_kodak: 'Kodak',
    stock_ferrania: 'Ferrania',
    stock_three_m: '3M',
    stock_agfa_gevaert: 'Agfa-Gevaert',
    stock_pathe: 'Pathe',
    stock_unknown: 'Unknown',
    ad_strip: 'AD strip',

  }
  MANIFEST_EXPORT = {
    'Year' => :year,
    'Gauge' => :gauge,
    'Film generation' => :film_generation,
    'Footage' => :footage,
    'Base' => :base,
    'Frame rate' => :frame_rate,
    'Color' => :color,
    'Aspect ratio' => :aspect_ratio,
    'Anamorphic' => :anamorphic,
    'Sound' => :sound,
    'Sound format type' => :sound_format_type,
    'Sound content type' => :sound_content_type,
    'Sound field' => :sound_field,
    'Clean' => :clean,
    'Resolution' => :resolution,
    'Color space' => :color_space,
    'Workflow' => :workflow,
    'On demand' => :on_demand,
    'Return on original reel' => :return_on_original_reel,
    'Film condition' => :film_condition,
    'Mold' => :mold,
    'Shrinkage' => :shrinkage,
    'AD strip' => :ad_strip,
    'Missing footage' => :missing_footage,
    'Track count' => :track_count,
    'Format duration' => :format_duration,
    'Stock' => :stock,
    'Conservation actions - IU' => :conservation_actions,
    'Miscellaneous' => :miscellaneous,
    'Return to' => :return_to
  }
  include TechnicalMetadatumModule
  include YearModule

  CONDITION_FIELDS = [:brittle, :broken, :channeling, :color_fade, :cue_marks, :dirty, :edge_damage, :holes, :peeling, :perforation_damage, :rusty, :scratches, :soundtrack_damage, :splice_damage, :stains, :sticky, :tape_residue, :tearing, :warp, :water_damage]
  def film_condition
    CONDITION_FIELDS.select { |f| self.send(f).to_i > 0 }.map { |f| "#{f.to_s.capitalize}: #{self.send(f)}" }.join(', ')
  end

  def default_values
  end

  def default_values_for_upload
    default_values
    self.frame_rate ||= ''
    self.sound ||= ''
    self.clean ||= ''
    self.resolution ||= ''
    self.workflow ||= ''
    self.on_demand ||= ''
    self.return_on_original_reel ||= ''
    self.mold ||= ''
    self.ad_strip ||= ''
    self.track_count ||= ''
    self.anamorphic ||= ''
  end

  # damage field
  def damage
    ''
  end

  # master_copies default of 1
end
