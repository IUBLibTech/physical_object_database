class QualityControlController < ApplicationController
	before_action :set_header_title
	before_action :set_staging, only: [:staging_index]

	def index
		if params[:status]
			@physical_objects = DigitalStatus.current_actionable_status(params[:status])
			ActiveRecord::Associations::Preloader.new.preload(@physical_objects, [:unit, :digital_statuses])
		end
	end

	def staging_index
		render "staging"
	end

	def staging_post
		if params[:selected]
			if params[:commit] and params[:commit] == "Stage Selected Objects"
				PhysicalObject.where(id: params[:selected].map(&:to_i)).update_all(staging_requested: true, staging_request_timestamp: DateTime.now)
			end
		end
		# this can't be done before the action it's reassigning staged/unstaged objects 
		set_staging
		render "staging"
	end

	def decide
		@ds = DigitalStatus.find(params[:id])
		@ds.update_attributes(decided: params[:decided])
		flash[:notice] = "Updated Digital Status for #{@ds.physical_object.mdpi_barcode} - chose #{@ds.decided}"
		render "index"
	end

	private
	def set_header_title
		@header_title = params[:status].nil? ? "" : params[:status].titleize
	end

	def set_staging
		if params[:date]
			begin
				date = DateTime.strptime(params[:date], "%m/%d/%Y")
			rescue
				flash[:warning] = "Invalid date - Please select from the Calendar or use mm/dd/yyyy"
				date = nil
			end
		end
		@unstaged = PhysicalObject.unstaged_by_date(date).eager_load(:digital_provenance).order(:digital_start)
		@staging_requested = PhysicalObject.staging_requested.eager_load(:digital_provenance)
		@staged = PhysicalObject.staged.eager_load(:digital_provenance).order(:updated_at)
	end


end
