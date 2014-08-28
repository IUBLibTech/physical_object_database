#
#
#
module TechnicalMetadatumClassModule

   # overridden to provide for more human readable attribute names for things like :sample_rate_32k
  def human_attribute_name(attribute, options = {})
    self.const_get(:HUMANIZED_COLUMNS)[attribute.to_sym] || super
  end

end
