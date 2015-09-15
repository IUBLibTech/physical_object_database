# Provides instance methods and class constants for physical objects,
# technical metadatum types.
#
module TechnicalMetadatumModule

  TMM_ERROR_CODE = 1000

  def hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end

  def TechnicalMetadatumModule.hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end

  TM_FORMAT_ARRAY = [ "CD-R", "DAT", "Open Reel Audio Tape", "LP", "Lacquer Disc", "45", "78", "Other Analog Sound Disc", "Betacam" ]

  TM_FORMATS = hashify(TM_FORMAT_ARRAY)

  TM_SUBTYPES = ["LP", "Lacquer Disc", "45", "78", "Other Analog Sound Disc"]

  BOX_FORMATS = [ "CD-R", "DAT", "LP", "Lacquer Disc", "45", "78", "Other Analog Sound Disc" ]

  BIN_FORMATS = [ "Open Reel Audio Tape", "Betacam" ]

  TM_GENRES = {
    "CD-R" => :audio,
    "DAT" => :audio,
    "Open Reel Audio Tape" => :audio,
    "LP" => :audio,
    "Lacquer Disc" => :audio,
    "45" => :audio,
    "78" => :audio,
    "Other Analog Sound Disc" => :audio,
    "Betacam" => :video
  }

  GENRE_EXTENSIONS = {
    audio: "wav",
    video: "mkv"
  }

  TM_FORMAT_CLASSES = {
    "CD-R" => CdrTm,
    "DAT" => DatTm,
    "Open Reel Audio Tape" => OpenReelTm,
    "LP" => AnalogSoundDiscTm,
    "Lacquer Disc" => AnalogSoundDiscTm,
    "45" => AnalogSoundDiscTm,
    "78" => AnalogSoundDiscTm,
    "Other Analog Sound Disc" => AnalogSoundDiscTm,
    "Betacam" => BetacamTm
  }

  # This only maps AnalogSoundDiscTm to one subtype, but that's okay.
  # In the 2 cases where this is used, it's suffient.
  # One case is determining valid import CSV headers.
  # The other case is mapping to partials (see immediately below).
  TM_CLASS_FORMATS = {
    CdrTm => "CD-R",
    DatTm => "DAT",
    OpenReelTm => "Open Reel Audio Tape",
    AnalogSoundDiscTm => "LP",
    BetacamTm => "Betacam"
  }

  TM_PARTIALS = {
    "CD-R" => "technical_metadatum/show_cdr_tm",
    "DAT" => "technical_metadatum/show_dat_tm",
    "Open Reel Audio Tape" => "technical_metadatum/show_open_reel_tape_tm",
    "LP" => "technical_metadatum/show_analog_sound_disc_tm",
    "Lacquer Disc" => "technical_metadatum/show_analog_sound_disc_tm",
    "45" => "technical_metadatum/show_analog_sound_disc_tm",
    "78" => "technical_metadatum/show_analog_sound_disc_tm",
    "Other Analog Sound Disc" => "technical_metadatum/show_analog_sound_disc_tm",
    "Betacam" => "technical_metadatum/show_betacam_tm",
    nil => "technical_metadatum/show_unknown_tm"
  }

  # # is this still used?
  # TM_CLASS_PICKLIST_PARTIALS = {
  #   CdrTm => "/picklists/cdr_tm",
  #   DatTm => "/picklists/dat_tm",
  #   OpenReelTm => "/picklists/open_reel_tm",
  #   AnalogSoundDiscTm => "/picklists/analog_sound_disc_tm"
  # }

  TM_TABLE_NAMES = {
    "CD-R" => "cdr_tms",
    "DAT" => "dat_tms",
    "Open Reel Audio Tape" => "open_reel_tms",
    "LP" => "analog_sound_disc_tms",
    "Lacquer Disc" => "analog_sound_disc_tms",
    "45" => "analog_sound_disc_tms",
    "78" => "analog_sound_disc_tms",
    "Other Analog Sound Disc" => "analog_sound_disc_tms",
    "Betacam" => "betacam_tms"
  }

  #default values
  PRESERVATION_PROBLEM_FIELDS = [] # common boolean fieldset
  HUMANIZED_COLUMNS = {} # optionally overrides humanized fieldname
  SIMPLE_FIELDS = [] # lists single-valued fields (selects, text entry)
  SELECT_FIELDS = {} # associates simple fields to select values
  MULTIVALUED_FIELDSETS = {} # associates description to boolean fieldset
  FIELDSET_COLUMNS = {} # sets boolean fields shown per row
  MANIFEST_EXPORT = {} # configures headers, fields for shipping manifest export

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
    self.const_set(:SELECT_FIELDS, SELECT_FIELDS) unless self.const_defined?(:SELECT_FIELDS)
    self.const_set(:MULTIVALUED_FIELDSETS, MULTIVALUED_FIELDSETS) unless self.const_defined?(:MULTIVALUED_FIELDSETS)
    self.const_set(:FIELDSET_COLUMNS, FIELDSET_COLUMNS) unless self.const_defined?(:FIELDSET_COLUMNS)
    self.const_set(:MANIFEST_EXPORT, MANIFEST_EXPORT) unless self.const_defined?(:MANIFEST_EXPORT)
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

  # customize to_xml output to group technical metadata Boolean fieldsets
  def to_xml(options = {})
    if self.class == PhysicalObject
      super(options)
    else
      # technical metadata formats
      require 'builder'
      options[:indent] ||= 2
      options[:dasherize] ||= false
      xml = options[:builder] ||= ::Builder::XmlMarkup.new(indent: options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.technical_metadata do
        if options[:format]
          xml.format options[:format]
        elsif self.technical_metadatum.physical_object
          xml.format self.technical_metadatum.physical_object.format
        else
          xml.format "Unknown"
        end
        xml.files self.master_copies
        self.class.const_get(:SIMPLE_FIELDS).each do |simple_attribute|
          spoofed_attribute_name = simple_attribute
          spoofed_attribute_name = simple_attribute.gsub("_", "-") if options[:dasherize]
          xml << "  <#{spoofed_attribute_name}>#{self.attributes[simple_attribute].to_s.encode(xml: :text)}</#{spoofed_attribute_name}>\n"
        end
        self.class.const_get(:MULTIVALUED_FIELDSETS).each do |name, fieldset|
          name = name.downcase.gsub(" ", "_")
          name = name.downcase.gsub("_", "-") if options[:dasherize]
          section_string = ""
          self.class.const_get(fieldset).each do |field|
            spoofed_field_name = field.to_s
            spoofed_field_name = field.to_s.gsub("_", "-") if options[:dasherize]
            section_string << "    <#{spoofed_field_name}>true</#{spoofed_field_name}>\n" if self.send((field.to_s + "?").to_sym)
          end
          if section_string.blank?
           section_string = "  <#{name}/>\n"
          else
           section_string = "  <#{name}>\n" + section_string + "  </#{name}>\n"
          end
          xml << section_string
	end
      end
    end
  end

  # for spreadsheet export
  def export_headers
    headers = self.class.const_get(:SIMPLE_FIELDS).map { |x| self.class.human_attribute_name(x) }
    headers += self.class.const_get(:MULTIVALUED_FIELDSETS).keys
  end

  # for spreadsheet export
  def export_values
    row_values = []
    self.class.const_get(:SIMPLE_FIELDS).each do |simple_attribute|
      row_values << self.attributes[simple_attribute]
    end
    self.class.const_get(:MULTIVALUED_FIELDSETS).values.each do |fieldset|
      row_values << humanize_boolean_fieldset(fieldset)
    end
    row_values
  end

  # for shipping manifest export
  def manifest_headers
    self.class.const_get(:MANIFEST_EXPORT).keys
  end

  # for shipping manifest export
  def manifest_values
    row_values = []
    multivalued_fieldsets = self.class.const_get(:MULTIVALUED_FIELDSETS).values
    fields = self.class.const_get(:MANIFEST_EXPORT).values
    fields.each do |field|
      if field.in? multivalued_fieldsets
        row_values << humanize_boolean_fieldset(field)
      else
        row_values << self.send(field)
      end
    end
    row_values
  end
end
