class DigitizationController < ApplicationController

	before_action :set_po, only: [:show, :edit, :update]

	def show
		@edit_mode = true
	end

	def edit
		@edit_mode = true
	end

	def update

	end

	private
	def set_po
		@physical_object = PhysicalObject.find(params[:id])
		authorize @physical_object
		@tm = @physical_object.technical_metadatum.specific
		@dp = @physical_object.digital_provenance
	end
end
