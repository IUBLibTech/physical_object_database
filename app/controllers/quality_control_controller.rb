class QualityControlController < ApplicationController
	before_action :set_header_title
	before_action :set_staging, only: [:staging_index]
	before_action :set_iu_staging, only: [:iu_staging_index]

	def index
		# This call is necessary as it initializes any staging percentages for formats that are present in the POD but not
		# present in the staging percentages table.
		StagingPercentagesController::validate_formats

		if params[:status]
			@physical_objects = DigitalStatus.current_actionable_status(params[:status])
			ActiveRecord::Associations::Preloader.new.preload(@physical_objects, [:unit, :digital_statuses])
		end
	end

	def iu_staging_index
		render 'staging'
	end

	def staging_index
		render 'staging'
	end

	def staging_post
		if params[:selected]
			if params[:commit] and params[:commit] == 'Stage Selected Objects'
				PhysicalObject.where(id: params[:selected].map(&:to_i)).update_all(staging_requested: true, staging_request_timestamp: DateTime.now)
			end
		end
		# this can't be done before the action it's reassigning staged/unstaged objects 
		set_staging
		# render 'staging'
		redirect_to :back
	end

	def stage
		begin
			po = PhysicalObject.find(params[:id])
			po.update_attributes(staging_requested: true)
			@success = true
			@msg = "Staging was successfully requested for PhysicalObject #{po.mdpi_barcode}."
		rescue ActiveRecord::RecordNotFound
			@success = false
			@msg = "ERROR: Could not find a record with id: #{params[:id]}."
		end
		render json: [@success, @msg]
	end

	# FIXME: I think this is only being referenced in spec tests now...
	def decide
		@ds = DigitalStatus.find(params[:id])
		@ds.update_attributes(decided: params[:decided], decided_manually: true)
		flash[:notice] = "Updated Digital Status for #{@ds.physical_object.mdpi_barcode} - chose #{@ds.decided}"
		render "index"
	end

	# displays auto_accept logs
	def auto_accept
	end

	def self.percent(format, entity)
		sp = StagingPercentage.where(format: format).first
		entity == "Memnon" ? sp.memnon_percent / 100.0 : sp.iu_percent / 100.0
	end

	private
	def set_header_title
		@header_title = params[:status].nil? ? "" : params[:status].titleize
		authorize :quality_control
	end

	def set_staging
		@action = 'staging_index'
		now = Time.now
		if params[:staging] && params[:staging][:date]
			@date = params[:staging][:date].blank? ? Time.new(now.year, now.month, now.day) : DateTime.strptime(params[:staging][:date], "%m/%d/%Y")
		else
			@date = Time.new(now.year, now.month, now.day)
		end
		@d_entity = "Memnon"

		formats = params[:staging].blank? || params[:staging][:format] == "All" ? PhysicalObject.memnon_unstaged_by_date_formats(@date) : [] << params[:staging][:format]
		@format_to_physical_objects = ActiveSupport::OrderedHash.new
		formats.each do |format|
			@format_to_physical_objects[format] = PhysicalObject.memnon_unstaged_by_date_and_format(@date, format)
		end
	end

	def set_iu_staging
		@action = "iu_staging_index"
		now = Time.now
		if params[:staging] && params[:staging][:date]
				@date = params[:staging][:date].blank? ? Time.new(now.year, now.month, now.day) : DateTime.strptime(params[:staging][:date], '%m/%d/%Y')
		else
			@date = Time.new(now.year, now.month, now.day)
		end
		@d_entity = "IU"
		formats = params[:staging].blank? || params[:staging][:format] == "All"  ? PhysicalObject.iu_unstaged_by_date_formats(@date) : [] << params[:staging][:format]
		@format_to_physical_objects = ActiveSupport::OrderedHash.new
		formats.each do |format|
			@format_to_physical_objects[format] = PhysicalObject.iu_unstaged_by_date_and_format(@date, format)
		end
	end




end
