class DatTm < ActiveRecord::Base
	acts_as :technical_metadatum

	# this hash holds the human reable attribute name for this class
	HUMANIZED_COLUMNS = {
    	:sample_rate_32k => "32k",
    	:sample_rate_44_1_k => "44.1k",
    	:sample_rate_48k => "48k",
    	:sample_rate_96k => "96k"
	}

  # overridden to provide for more human readable attribute names for things like :sample_rate_32k
  def self.human_attribute_name(attribute)
    HUMANIZED_COLUMNS[attribute.to_sym] || super
  end
	
	def humanize_boolean_fields(*field_names)
  	str = ""
  	field_names.each do |f|
  		str << ((!self[f].nil? and self[f]) ? (str.length > 0 ? ", " << DatTm.human_attribute_name(f) : DatTm.human_attribute_name(f)) : "")
  	end
  	str
  end
end
