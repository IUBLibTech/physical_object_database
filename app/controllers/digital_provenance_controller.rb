class DigitalProvenanceController < ApplicationController
	include ApplicationHelper

	before_action :set_po, only: [:show, :edit, :update]
	before_action :set_nexts, only: [:show, :edit]

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

  #destroy action not available, but listed for policy method creation
  def destroy
    flash[:warning] = 'Destroy action unavailable.'
    redirect_to action: show
  end

	private
	def set_po
		@physical_object = PhysicalObject.find(params[:id])
		@tm = @physical_object.technical_metadatum.specific
		@dp = @physical_object.digital_provenance
		authorize @dp
	end

  def set_nexts
    @bin = @physical_object&.bin
    @batch = @bin&.batch
    if @bin
      @next_po = @bin.physical_objects.order(:call_number).select { |po| po.call_number > @physical_object.call_number }.first
    end
    if @batch
      @next_bin = @batch.bins.order(:identifier).select { |bin| bin.identifier > @bin.identifier }.first
    end
  end
	
end
