# Provides instance methods and class constants for physical objects,
# technical metadatum types.
#
# Including classes update the instance variables, which must be set
# as constants by calling set_tm_constants.
# The last 2 lines of this file take care of this, after the module is loaded.
#
# RSpec testing is via shared shared examples call in including models
module TechnicalMetadatumModule

  TMM_ERROR_CODE = 1000

  def hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end

  def TechnicalMetadatumModule.hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end

  # For module: constants to track values from included classes
  @@tm_formats_array ||= []
  @@tm_formats_hash ||= {}
  @@tm_subtypes ||= []
  @@box_formats ||= []
  @@bin_formats ||= []
  @@tm_genres ||= {}
  @@tm_format_classes ||= {}
  # This only maps a class to one subtype, but that's okay.
  # In the 2 cases where this is used, it's suffient, as the subtypes should behave equivalently.
  # One case is determining valid import CSV headers.
  # The other case is mapping to partials (see immediately below).
  @@tm_class_formats ||= {}
  @@tm_partials ||= { nil => 'show_unknown_tm' }
  @@tm_table_names ||= {}

  mattr_reader :tm_formats_array, :tm_formats_hash, :tm_subtypes, :box_formats, :bin_formats, :tm_genres, :tm_format_classes, :tm_class_formats, :tm_partials, :tm_table_names

  # Pre-set module constants
  GENRE_EXTENSIONS = {
    audio: "wav",
    video: "mkv"
  }

  GENRE_AUTO_ACCEPT_DAYS = {
    audio: 40,
    video: 30
  }

  # For including classes: set empty default values, which class can override
  PRESERVATION_PROBLEM_FIELDS = [] # common boolean fieldset
  HUMANIZED_COLUMNS = {} # optionally overrides humanized fieldname
  SIMPLE_FIELDS = [] # lists single-valued fields (selects, text entry)
  SELECT_FIELDS = {} # associates simple fields to select values
  MULTIVALUED_FIELDSETS = {} # associates description to boolean fieldset
  FIELDSET_COLUMNS = {} # sets boolean fields shown per row
  MANIFEST_EXPORT = {} # configures headers, fields for shipping manifest export
  # configures uniform required (true)/optional (false)/na (nil) provenance fields
  PROVENANCE_REQUIREMENTS = {
    comments: false,
    cleaning_comment: false,
    cleaning_date: false,
    repaired: false,
    duration: true,
    batch_processing_flag: false,

    filename: true,
    date_digitized: true,
    comment: false,
    created_by: true,
    signal_chain_id: true
  } 

  # Track values from including classes
  def self.included(base)
    if base.const_defined?(:TM_FORMAT)
      # Update module constants to track class values
      tm_formats = base.const_get(:TM_FORMAT)
      @@tm_formats_array += tm_formats
      @@tm_formats_hash = hashify(@@tm_formats_array)
      @@tm_subtypes += tm_formats if base.const_defined?(:TM_SUBTYPE) && base.const_get(:TM_SUBTYPE)
      @@box_formats += tm_formats if base.const_defined?(:BOX_FORMAT) && base.const_get(:BOX_FORMAT)
      @@bin_formats += tm_formats if base.const_defined?(:BIN_FORMAT) && base.const_get(:BIN_FORMAT)
      @@tm_class_formats = @@tm_class_formats.merge({ base => tm_formats.first })
      tm_formats.each do |tm_format|
        @@tm_genres = @@tm_genres.merge({ tm_format => base.const_get(:TM_GENRE)}) if base.const_defined?(:TM_GENRE)
        if base.const_defined?(:TM_PARTIAL)
          @@tm_partials = @@tm_partials.merge({ tm_format => base.const_get(:TM_PARTIAL)})
        else
          @@tm_partials = @@tm_partials.merge({ tm_format => 'show_generic_tm'})  
        end
        @@tm_format_classes = @@tm_format_classes.merge({ tm_format => base })
        @@tm_table_names = @@tm_table_names.merge({ tm_format => base.table_name})
      end

      # Update class
      # Select values: object values list methods, validations
      base.constants.map { |c| c.to_s }.select { |c| c.match /^.*_VALUES$/ }.each do |values_constant|
        fieldname = values_constant.match(/^(.*)_VALUES/)[1].downcase
        base.class_eval do
          # Select values method on object
          define_method(values_constant.downcase) do
            self.class.const_get(values_constant.to_sym)
          end
          # Select values validation
          validates fieldname.to_sym, inclusion: { in: base.const_get(values_constant.to_sym).keys }
        end
      end
      # SELECT_FIELDS constant on class
      base.const_set(:SELECT_FIELDS, Hash[base.constants.map { |c| c.to_s }.select { |c| c.match /^.*_VALUES$/ }.map{ |v| [v.match(/^(.*)_VALUES/)[1].downcase,base.const_get(v.to_sym)] }])
      # Boolean fieldsets: display methods for fieldsets
      base.constants.map { |c| c.to_s }.select { |c| c.match /^.*_FIELDS$/ }.each do |values_constant|
        fieldset = values_constant.match(/^(.*)_FIELDS/)[1].downcase
        base.class_eval do
          define_method(fieldset) do
            humanize_boolean_fieldset(values_constant.to_sym)
          end
        end
      end
    end
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

  def TechnicalMetadatumModule.format_auto_accept_days(format)
    GENRE_AUTO_ACCEPT_DAYS[tm_genres[format]]
  end

  def provenance_requirements
    self.class::PROVENANCE_REQUIREMENTS
  end

end
