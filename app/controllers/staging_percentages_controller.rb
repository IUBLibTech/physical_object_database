class StagingPercentagesController < ApplicationController
	before_action { authorize :staging_percentage }
	def index
		StagingPercentagesController::validate_formats
		@percentages = StagingPercentage.all.order(:format)
	end

	def update
		@percentage = StagingPercentage.find(params[:id])
		success = @percentage.update_attributes(staging_percentage_params)
		flash.now[:notice] = "#{@percentage.format} updated. Memnon: #{@percentage.memnon_percent}%, IU: #{@percentage.iu_percent}%" if success
		flash.now[:warning] = "#{@percentage.format} could not be saved" if !success
		@percentages = StagingPercentage.all.order(:format)
		render :index
	end

	def self.validate_formats
		# those formats for which there exists a staging percent for memnon/iu
		defined = StagingPercentage.all.order(:format).pluck("format")
		# all formats that are represented in the POD - from the technical metadata table
		all_formats = PhysicalObject.valid_formats
		difference = (all_formats - defined) | (defined - all_formats)
		puts "Difference in formats: #{difference}"
		difference.each do |format|
			sp = StagingPercentage.new(format: format, memnon_percent: StagingPercentage::default_percentage, iu_percent: StagingPercentage::default_percentage)
			saved = sp.save
		end
	end

	private
	def staging_percentage_params
		params.require(:staging_percentage).permit(:memnon_percent, :iu_percent)
	end

	def error_messages_for(object)
		render(partial: 'application/error_messages', locals: {object: object})
	end



end
