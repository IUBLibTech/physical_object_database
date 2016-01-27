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
		  if dfp.valid? && dfp.save && dfp.persisted?
puts dfp.inspect
		    flash[:warning] = "Digital File Provenance has been saved, but is not complete." unless dfp.complete? || dfp._destroy
		  else
		    success_flag = false
		  end
		end
		if @dp.valid? && @dp.save
		  flash[:warning] = "Digital Provenance has been saved, but is not complete." unless @dp.complete?
		else
		  success_flag = false
		end
		if success_flag
			flash[:notice] = "Digital Provenance has been saved."
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
		@tm = @physical_object.technical_metadatum.specific
		@dp = @physical_object.digital_provenance
		authorize @dp
	end
	
end
