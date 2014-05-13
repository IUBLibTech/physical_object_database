class OpenReelTm < ActiveRecord::Base
	acts_as :technical_metadatum

	# this hash holds the human reable attribute name for this class
	HUMANIZED_COLUMNS = {:zero_point9375_ips => "0.9375 ips", :one_point875_ips => "1.875 ips", 
		:three_point75_ips => "3.75 ips", :seven_point5_ips => "7.5 ips", :fifteen_ips => "15 ips", 
		:thirty_ips => "30 ips", :unknown_track => "Unknown", :zero_point5_mils => "0.5 mil",
		:one_mils => "1 mil", :one_point5_mils => "1.5 mil", :unknown_sound_field => "Unknown", 
		:acetate_base => "Acetate", :polyester_base => "Polyester", :pvc_base => "PVC", :paper_base => "Paper",
		:unknown_playback_speed => "Unknown", :one_direction => "1", :two_directions => "2", :unknown_direction => "Unknown" 
	}

	attr_accessor :reel_sizes
	def reel_sizes
		{"" => "", "5 in." => "5 in.", "7 in." => "7 in.", "10.5 in." => "10.5 in."} 
	end

	attr_accessor :pack_deformations
	def pack_deformations
		{"" => "", "Minor" => "Minor", "Moderate" => "Moderate", "Severe" => "Severe"}
	end

	attr_accessor :directions_recorded_vals
	def directions_recorded_vals
		{"" => "", "1" => "1", "2" => "2"}
	end

	def generalize
    TechnicalMetadatum.find_by(as_technical_metadatum_id: self.id)
  end

  def humanize_boolean_fields(*field_names)
  	str = ""
  	field_names.each do |f|
  		str << ((!self[f].nil? and self[f]) ? (str.length > 0 ? ", " << OpenReelTm.human_attribute_name(f) : OpenReelTm.human_attribute_name(f)) : "")
  	end
  	str
  end

  # overridden to provide for more human readable attribute names for things like :zero_point9375_ips
  def self.human_attribute_name(attribute)
    HUMANIZED_COLUMNS[attribute.to_sym] || super
  end

end
