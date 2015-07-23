class DigitalProvenanceController < ApplicationController

	before_action :set_po, only: [:show, :edit, :update]

	# converts the mm/dd/yyyy format of jquery datepicker field into something that rails can
	# correctly parse into a datetime
	before_action :normalize_dates, only: [:update]

	def show
		
	end

	def edit
		@edit_mode = true
	end

	def update
		if @dp.update_attributes(dp_params)
			redirect_to action: :show
		else
			@edit_mode = true
			render action: :edit 
		end
	end

	private
	def set_po
		@physical_object = PhysicalObject.find(params[:id])
		@tm = @physical_object.technical_metadatum.as_technical_metadatum
		@dp = @physical_object.digital_provenance
	end
	
end
