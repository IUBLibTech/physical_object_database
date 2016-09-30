# Provides class methods for physical objects, technical metadatum types.
#
# RSpec testing is via shared shared examples call in extending models
module TechnicalMetadatumClassModule

   # overridden to provide for more human readable attribute names for things like :sample_rate_32k
  def human_attribute_name(attribute, options = {})
    self.const_get(:HUMANIZED_COLUMNS)[attribute.to_sym] || super
  end

  def hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end

  def parse_tm(tm, row)
    self.const_get(:SIMPLE_FIELDS).each do |fieldname|
      value = row[self.human_attribute_name(fieldname)].to_s
      tm.send((fieldname + "=").to_sym, value) if value.present?
    end

    self.const_get(:MULTIVALUED_FIELDSETS).each_pair do |key, value|
      row_values = row[key].to_s.split(/\s*,\s*/)
      fieldset = self.const_get(value)
      valid_imports = fieldset.map { |x| self.human_attribute_name(x) }
      unless row_values.empty?
        fieldset.each do |fieldname|
          tm.send((fieldname + "=").to_sym, row_values.include?(self.human_attribute_name(fieldname)))
        end
      end
      row_values.each do |import_field|
        if !valid_imports.include? import_field
	  tm.errors.add :base, "\"#{import_field}\" is not a valid value for #{key}.  Valid values are: #{valid_imports.join(', ')}"
	end
      end
    end
  end

  #returns valid headers for CSV upload
  def valid_headers
      self.const_get(:SIMPLE_FIELDS).map { |field| self.human_attribute_name(field) } + self.const_get(:MULTIVALUED_FIELDSETS).keys
  end

end
