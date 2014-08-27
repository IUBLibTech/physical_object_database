#
#
#
module TechnicalMetadatumModule

  TM_FORMATS = {
    "CD-R" => "CD-R",
    "DAT" => "DAT",
    "Open Reel Audio Tape" => "Open Reel Audio Tape"
  }

  TM_FORMAT_CLASSES = {
    "CD-R" => CdrTm,
    "DAT" => DatTm,
    "Open Reel Audio Tape" => OpenReelTm
  }

  TM_CLASS_FORMATS = {
    CdrTm => "CD-R",
    DatTm => "DAT",
    OpenReelTm => "Open Reel Audio Tape"
  }

  TM_PARTIALS = {
    "CD-R" => "technical_metadatum/show_cdr_tm",
    "DAT" => "technical_metadatum/show_dat_tm",
    "Open Reel Audio Tape" => "technical_metadatum/show_open_reel_tape_tm",
    nil => "technical_metadatum/show_unknown_tm"
  }

  TM_TABLE_NAMES = {
    "CD-R" => "cdr_tms",
    "DAT" => "dat_tms",
    "Open Reel Audio Tape" => "open_reel_tms"
  }

  #include instance methods, class methods, default class constants
  def self.included(base)
    base.extend(ClassMethods)
    self.const_set(:TM_FORMATS, TM_FORMATS)
    self.const_set(:TM_FORMAT_CLASSES, TM_FORMAT_CLASSES)
    self.const_set(:TM_CLASS_FORMATS, TM_CLASS_FORMATS)
    self.const_set(:TM_PARTIALS, TM_PARTIALS)
    unless self.const_defined?(:HUMANIZED_COLUMNS)
      self.const_set(:HUMANIZED_COLUMNS, {})
    end
  end

  def humanize_boolean_fields(field_names)
    str = ""
    field_names.each do |f|
      str << (self[f] ? (str.length > 0 ? ", " << self.class.human_attribute_name(f) : self.class.human_attribute_name(f)) : "")
    end
    str
  end

  module ClassMethods
   # overridden to provide for more human readable attribute names for things like :sample_rate_32k
    def human_attribute_name(attribute)
      self::HUMANIZED_COLUMNS[attribute.to_sym] || super
    end
  end

end
