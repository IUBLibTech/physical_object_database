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
		success_flag = true
		@dp.assign_attributes(dp_params)
		@dp.digital_file_provenances.each do |dfp|
		  if dfp.valid? && dfp.save
		    # do nothing
		  else
		    succes_flag = false
		  end
		end
		if @dp.valid? && @dp.save
		  # do nothing
		else
		  success_flag = false
		end
		if success_flag
			redirect_to action: :show
		else
			@edit_mode = true
			render action: :edit 
		end
	end

  def destroy
    flash[:warning] = "Digital Provenance may not be deleted."
    redirect_to action: :show
  end

	private
	def set_po
		@physical_object = PhysicalObject.find(params[:id])
		@tm = @physical_object.technical_metadatum.as_technical_metadatum
		@dp = @physical_object.digital_provenance
		authorize @dp
	end
	
end
