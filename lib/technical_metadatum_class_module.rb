#
#
#
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
      tm.send((fieldname + "=").to_sym, row[self.human_attribute_name(fieldname)])
    end

    self.const_get(:MULTIVALUED_FIELDSETS).each_pair do |key, value|
      row_values = row[key]
      unless row_values.nil? || row_values.blank?
        self.const_get(value).each do |fieldname|
          tm.send((fieldname + "=").to_sym, row_values.include?(self.human_attribute_name(fieldname)))
        end
      end
    end
  end

end
