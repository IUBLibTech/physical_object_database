class QualityControlController < ApplicationController

	def index
		if params[:status]
			@physical_objects = DigitalStatus.current_status(params[:status])
		end
	end

end
