class OpenReelTm < ActiveRecord::Base
	acts_as :technical_metadatum

	attr_accessor :reel_sizes
	def reel_sizes
		{"" => "", "5\"" => "5\"", "7\"" => "7\"", "10.5\"" => "10.5\""} 
	end

	attr_accessor :playback_speeds
	def playback_speeds
		{"" => "", "1.78 ips" => "1.78 ips", "3.75 ips" => "3.75 ips", "7.5 ips" => "7.5 ips" }
	end

	attr_accessor :pack_deformations
	def pack_deformations
		{"" => "", "Minor" => "Minor", "Moderate" => "Moderate", "Severe" => "Severe"}
	end

	attr_accessor :preservation_problems
	def preservation_problems
		{"" => "", "Sticky Shed Syndrome" => "Sticky Shed Syndrome", 
			"Fungus" => "Fungus", "Vinegar Syndrome" => "Vinegar Syndrome"}
	end

	attr_accessor :track_configurations
	def track_configurations
		{"" => "", "Full Track" => "Full Track", "Half Track" => "Half Track", "Quarter Track" => "Quarter Track"}
	end

	attr_accessor :tape_thicknesses
	def tape_thicknesses
		{
			"" => "", 
			"0.5 mil (double and triple play)" => "0.5 mil (double and triple play)", 
			"1.0 mil (long play)" => "1.0 mil (long play)", 
			"1.5 mil (standard play)" => "1.5 mil (standard play)"
		}
	end

	attr_accessor :sound_fields
	def sound_fields
		{"" => "", "Mono" => "Mono", "Stereo" => "Stereo"}
	end

	attr_accessor :tape_stock_brands
	def tape_stock_brands
		{"" => "", "Scotch 208" => "Scotch 208", "Ampex 631" => "Ampex 631"}
	end

	attr_accessor :tape_bases
	def tape_bases
		{"" => "", "Polyester" => "Polyester", "Acetate" => "Acetate", "PVC" => "PVC"}
	end


	def generalize
    TechnicalMetadatum.find_by(as_technical_metadatum_id: self.id)
  end

	def update_form_params(params)
		puts(params.to_yaml)
    params.require(:open_reel_tm).permit(:pack_deformation, :preservation_problem, :reel_size,
    	:playback_speed, :track_configuration, :tape_thickness, :sound_field, :tape_stock_brand,
    	:tape_base, :year_of_recording, :directions_recorded)
  end

end
