class OpenReelTm < ActiveRecord::Base
	acts_as :technical_metadatum

	attr_accessor :reel_sizes
	def reel_sizes
		{"" => "", "5 in." => "5 in.", "7 in." => "7 in.", "10.5 in." => "10.5 in."} 
	end

	attr_accessor :playback_speeds
	def playback_speeds
		{"" => "", "1.78 ips" => "1.78 ips", "3.75 ips" => "3.75 ips", "7.5 ips" => "7.5 ips" }
	end

	attr_accessor :pack_deformations
	def pack_deformations
		{"" => "", "Minor" => "Minor", "Moderate" => "Moderate", "Severe" => "Severe"}
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

	attr_accessor :directions_recorded_vals
	def directions_recorded_vals
		{"" => "", "1" => "1", "2" => "2", "3" => "3", "4" => "4"}
	end

	def generalize
    TechnicalMetadatum.find_by(as_technical_metadatum_id: self.id)
  end

  def humanize_preservation_problems
  	str = (!fungus.nil? and fungus) ? "Fungus" : ""
  	str << ((!soft_binder_syndrome.nil? and soft_binder_syndrome) ? (str.length > 0 ? ", Soft Binder Syndrome" : "Soft Binder Syndrome") : "")
  	str << ((!vinegar_syndrome.nil? and vinegar_syndrome) ? (str.length > 0 ? ", Vinegar Syndrome" : "Vinegar Syndrome") : "")
  	str << ((!other_contaminants.nil? and other_contaminants) ? (str.length > 0 ? ", Other Contaminants" : "Other Contaminants") : "")
  	str
  end

	def update_form_params(params)
		self.pack_deformation = params[:technical_metadata][:pack_deformation]
 		self.reel_size = params[:technical_metadata][:reel_size]
 		if self.preservation_problems.nil?
 			self.preservation_problems = PreservationProblems.new
 		end
 		self.preservation_problems.update_params(params[:preservation_problems])

 		self.playback_speed = params[:technical_metadata][:playback_speed]
 		self.track_configuration = params[:technical_metadata][:track_configuration]
 		self.tape_thickness = params[:technical_metadata][:tape_thickness]
 		self.sound_field = params[:technical_metadata][:sound_field]
 		self.tape_stock_brand = params[:technical_metadata][:tape_stock_brand]
 		self.tape_base = params[:technical_metadata][:tape_base]
 		self.directions_recorded = params[:technical_metadata][:directions_recorded]
  end

end
