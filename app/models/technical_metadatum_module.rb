#
#
#
module TechnicalMetadatumModule

  #include instance methods, class methods, default class constants
  def self.included(base)
    base.extend(ClassMethods)
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
