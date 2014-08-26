class AnalogSoundDiscTm < ActiveRecord::Base
	acts_as :technical_metadatum
	after_initialize :default_values

	def default_values
		if subtype == "LP"
			self.diameter ||= 12
			self.speed ||= 33.3
			self.groove_size ||= "Micro"
			self.groove_orientation ||= "Lateral"
			self.recording_method ||= "Pressed"
			self.substrate ||= "N/A"
			self.coating ||="N/A"
			self.material ||= "Plastic"
		end
	end

	def humanize_boolean_fields(*field_names)
		str = ""
  	field_names.each do |f|
  		str << ((!self[f].nil? and self[f]) ? (str.length > 0 ? ", " << AnalogSoundDiscTm.human_attribute_name(f) : AnalogSoundDiscTm.human_attribute_name(f)) : "")
  	end
  	str
	end

	def diameter_values
		{5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 12 => 12, 16 => 16}
	end

	def speed_values
		{33.3 => 33.3, 45 => 45, 78 => 78 }
		
	end
	
	def groove_size_values
		{"Coarse" => "Coarse", "Micro" => "Micro"}
	end
	
	def groove_orientation_values
		{"Lateral" => "Lateral", "Vertical" => "Vertical"}
	end

	def recording_method_values
		{"Pressed" => "Pressed", "Cut" => "Cut", "Pregrooved" => "Pregrooved"}
	end

	def material_values
		{"Shellac" => "Shellac", "Plastic" => "Plastic", "N/A" => "N/A"}
	end

	def substrate_values
		{"Aluminum" => "Aluminum", "Glass" =>"Glass", "Fiber" => "Fiber", "Steel" => "Steel", "Zinc" => "Zinc", "N/A" => "N/A"}
	end

	def coating_values
		{"None" => "None", "Lacquer" => "Lacquer", "N/A" => "N/A"}
	end

	def equalization_values
		{"RIAA" => "RIAA", "Other" => "Other", "Unknown" => "Unknown"}
	end

	def sound_field_values
		{"Mono" => "Mono", "Stereo" => "Stereo", "Unknown" => "Unknown"}
	end
end
