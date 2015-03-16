# Provides instance methods and class constants for physical objects,
# technical metadatum types.
#
module TechnicalMetadatumModule

  def hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end
  def TechnicalMetadatumModule.hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end

  TM_FORMAT_ARRAY = [ "CD-R", "DAT", "Open Reel Audio Tape", "LP" ]

  TM_FORMATS = hashify(TM_FORMAT_ARRAY)

  TM_SUBTYPES = ["LP"]

  TM_GENRES = {
    "CD-R" => :audio,
    "DAT" => :audio,
    "Open Reel Audio Tape" => :audio,
    "LP" => :audio
  }

  TM_FORMAT_CLASSES = {
    "CD-R" => CdrTm,
    "DAT" => DatTm,
    "Open Reel Audio Tape" => OpenReelTm,
    "LP" => AnalogSoundDiscTm
  }

  TM_CLASS_FORMATS = {
    CdrTm => "CD-R",
    DatTm => "DAT",
    OpenReelTm => "Open Reel Audio Tape",
    AnalogSoundDiscTm => "LP"
  }

  TM_PARTIALS = {
    "CD-R" => "technical_metadatum/show_cdr_tm",
    "DAT" => "technical_metadatum/show_dat_tm",
    "Open Reel Audio Tape" => "technical_metadatum/show_open_reel_tape_tm",
    "LP" => "technical_metadatum/show_analog_sound_disc_tm",
    nil => "technical_metadatum/show_unknown_tm"
  }

  TM_CLASS_PICKLIST_PARTIALS = {
    CdrTm => "/picklists/cdr_tm",
    DatTm => "/picklists/dat_tm",
    OpenReelTm => "/picklists/open_reel_tm",
    AnalogSoundDiscTm => "/picklists/analog_sound_disc_tm"
  }

  TM_TABLE_NAMES = {
    "CD-R" => "cdr_tms",
    "DAT" => "dat_tms",
    "Open Reel Audio Tape" => "open_reel_tms",
    "LP" => "analog_sound_disc_tms"
  }

  #default values
  PRESERVATION_PROBLEM_FIELDS = []
  HUMANIZED_COLUMNS = {}
  SIMPLE_FIELDS = []
  MULTIVALUED_FIELDSETS = {}

  #include instance methods, class methods, default class constants
  def self.included(base)
    #base.extend(ClassMethods)
    self.const_set(:TM_FORMATS, TM_FORMATS) unless self.const_defined?(:TM_FORMATS)
    self.const_set(:TM_SUBTYPES, TM_SUBTYPES) unless self.const_defined?(:TM_SUBTYPES)
    self.const_set(:TM_GENRES, TM_GENRES) unless self.const_defined?(:TM_GENRES)
    self.const_set(:TM_FORMAT_CLASSES, TM_FORMAT_CLASSES) unless self.const_defined?(:TM_FORMAT_CLASSES)
    self.const_set(:TM_CLASS_FORMATS, TM_CLASS_FORMATS) unless self.const_defined?(:TM_CLASS_FORMATS)
    self.const_set(:TM_PARTIALS, TM_PARTIALS) unless self.const_defined?(:TM_PARTIALS)
    self.const_set(:TM_TABLE_NAMES, TM_TABLE_NAMES) unless self.const_defined?(:TM_TABLE_NAMES)
    #default empty values
    self.const_set(:PRESERVATION_PROBLEM_FIELDS, PRESERVATION_PROBLEM_FIELDS) unless self.const_defined?(:PRESERVATION_PROBLEM_FIELDS)
    self.const_set(:HUMANIZED_COLUMNS, HUMANIZED_COLUMNS) unless self.const_defined?(:HUMANIZED_COLUMNS)
    self.const_set(:SIMPLE_FIELDS, SIMPLE_FIELDS) unless self.const_defined?(:SIMPLE_FIELDS)
    self.const_set(:MULTIVALUED_FIELDSETS, MULTIVALUED_FIELDSETS) unless self.const_defined?(:MULTIVALUED_FIELDSETS)
  end

  def humanize_boolean_fields(*field_names)
    str = ""
    field_names.each do |f|
      str << (self[f] ? (str.length > 0 ? ", " << self.class.human_attribute_name(f) : self.class.human_attribute_name(f)) : "")
    end
    str
  end

  def humanize_boolean_fieldset(fieldset_symbol)
    humanize_boolean_fields(*self.class.const_get(fieldset_symbol))
  end

  def preservation_problems
    humanize_boolean_fieldset(:PRESERVATION_PROBLEM_FIELDS)
  end

  #override when needed
  def master_copies
    1
  end

end
