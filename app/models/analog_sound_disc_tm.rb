class AnalogSoundDiscTm < ActiveRecord::Base
	acts_as :technical_metadatum
	after_initialize :default_values
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule

	PRESERVATION_PROBLEM_FIELDS = [
	  "delamination", "exudation", "oxidation"
	]
	DAMAGE_FIELDS = [
	  "broken", "cracked", "dirty", "fungus", "scratched", "warped", "worn"
	]
	DIAMETER_VALUES = hashify [5, 6, 7, 8, 9, 10, 12, 16]
	SPEED_VALUES = hashify [33.3, 45, 78]
	GROOVE_SIZE_VALUES = hashify ['Coarse', 'Micro']
	GROOVE_ORIENTATION_VALUES = hashify ['Lateral', 'Vertical']
	RECORDING_METHOD_VALUES = hashify ['Pressed', 'Cut', 'Pregrooved']
	MATERIAL_VALUES = hashify ['Shellac', 'Plastic', 'N/A']
	SUBSTRATE_VALUES = hashify ["Aluminum", "Glass", "Fiber", "Steel", "Zinc", "N/A"]
	COATING_VALUES = hashify ['None', 'Lacquer', 'N/A']
	EQUALIZATION_VALUES = hashify ['', 'RIAA', 'Other', 'Unknown']
	SOUND_FIELD_VALUES = hashify ['Mono', 'Stereo', 'Unknown']
	SUBTYPE_VALUES = hashify ['LP', 'Lacquer Disc', 'Other Analog Sound Disc']
	#FIXME: include subtype as simple field?
	SIMPLE_FIELDS = [
          "diameter", "speed", "groove_size", "groove_orientation",
	  "recording_method", "material", "substrate", "coating",
	  "equalization", "sound_field", "country_of_origin", "label"
	]
	MULTIVALUED_FIELDSETS = {
	  "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS,
	  "Damage" => :DAMAGE_FIELDS,
	}

	validates :diameter, inclusion: { in: DIAMETER_VALUES.keys }
	validates :speed, inclusion: { in: SPEED_VALUES.keys }
	validates :groove_size, inclusion: { in: GROOVE_SIZE_VALUES.keys }
	validates :groove_orientation, inclusion: { in: GROOVE_ORIENTATION_VALUES.keys }
	validates :recording_method, inclusion: { in: RECORDING_METHOD_VALUES.keys }
	validates :material, inclusion: { in: MATERIAL_VALUES.keys }
	validates :substrate, inclusion: { in: SUBSTRATE_VALUES.keys }
	validates :coating, inclusion: { in: COATING_VALUES.keys }
	validates :equalization, inclusion: { in: EQUALIZATION_VALUES.keys }
	validates :sound_field, inclusion: { in: SOUND_FIELD_VALUES.keys }
	validates :subtype, inclusion: { in: SUBTYPE_VALUES.keys }

	#NOTE: default values must be string values
	DEFAULT_VALUES = {
		"LP" => { diameter: "12",
			  speed: "33.3",
			  groove_size: "Micro",
			  groove_orientation: "Lateral",
			  sound_field: "Unknown",
			  recording_method: "Pressed",
			  substrate: "N/A",
			  coating: "N/A",
			  material: "Plastic",
			  equalization: ""
			},
		"Lacquer Disc" => { diameter: nil,
			  speed: nil,
			  groove_size: nil,
			  groove_orientation: "Lateral",
			  sound_field: "Mono",
			  recording_method: "Cut",
			  substrate: "Aluminum",
			  coating: "Lacquer",
			  material: "N/A",
			  equalization: "Other"
			},
		"Other Analog Sound Disc" => { diameter: nil,
			  speed: nil,
			  groove_size: nil,
			  groove_orientation: nil,
			  sound_field: nil,
			  recording_method: nil,
			  substrate: nil,
			  coating: nil,
			  material: nil,
			  equalization: nil
			}
	}

	def default_values
		values_hash = DEFAULT_VALUES[subtype]
		unless values_hash.nil?
			self.diameter ||= values_hash[:diameter]
			self.speed ||= values_hash[:speed]
			self.groove_size ||= values_hash[:groove_size]
			self.groove_orientation ||= values_hash[:groove_orientation]
			self.sound_field ||= values_hash[:sound_field]
			self.recording_method ||= values_hash[:recording_method]
			self.substrate ||= values_hash[:substrate]
			self.coating ||= values_hash[:coating]
			self.material ||= values_hash[:material]
			self.equalization ||= values_hash[:equalization]
		end
	end

	def diameter_values
		DIAMETER_VALUES
	end

	def speed_values
        	SPEED_VALUES
	end
	
	def groove_size_values
        	GROOVE_SIZE_VALUES
	end
	
	def groove_orientation_values
		GROOVE_ORIENTATION_VALUES
	end

	def recording_method_values
		RECORDING_METHOD_VALUES
	end

	def material_values
		MATERIAL_VALUES
	end

	def substrate_values
		SUBSTRATE_VALUES
	end

	def coating_values
		COATING_VALUES
	end

	def equalization_values
		EQUALIZATION_VALUES
	end

	def sound_field_values
		SOUND_FIELD_VALUES
	end

	def damage
		humanize_boolean_fieldset(:DAMAGE_FIELDS)
	end

	def master_copies
		2
	end

end
