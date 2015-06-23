class DigitizationController < ApplicationController

	before_action :set_po, only: [:show, :edit, :update]

	def show
		@edit_mode = true
	end

	def edit

	end

	def update

	end

	private
	def set_po
		@physical_object = PhysicalObject.find(params[:id])
		@dp = @physical_object.digital_provenance
	end
end
