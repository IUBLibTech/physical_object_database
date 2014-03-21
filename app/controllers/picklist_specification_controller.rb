class PicklistSpecificationController < ApplicationController

	def index
		@picklists = PicklistSpecification.all
	end

	def new
		@formats = PhysicalObject.new.formats
		@ps = PicklistSpecification.new(format: params[:format])
		@action = 'create'
		@submit_text = "Create New Picklist Specification"
	end

	def create
		@ps = PicklistSpecification.new(picklist_specification_params)
		@tm = @ps.init_tm
		@tm.picklist_specification = @ps;
		@tm.update_attributes(@tm.update_form_params(params[:ps]))
		
		redirect_to(action: 'index')
	end

	def edit
		@ps = PicklistSpecification.find(params[:id])
		@tm = @ps.technical_metadata[0].specialize
		@edit_mode = true
		@action = 'update'
		@submit_text = "Update Picklist Specification"
	end

	def update
		@ps = PicklistSpecification.find(params[:id])
		if (@ps.update_attributes(picklist_specification_params))
			@tm = @ps.technical_metadata[0].specialize
			@tm.update_attributes(@tm.update_form_params(params[:ps]))
			flash[:notice] = "#{@ps.name} successfully updated."
		else
			flash[:notice] = "Failed to update #{@ps.name}."
		end
		redirect_to(action: 'index')
	end

	def show
		@ps = PicklistSpecification.find(params[:id])
		@tm = @ps.technical_metadata[0].specialize
		@edit_mode = false
	end

	def destroy
		@ps = PicklistSpecification.find(params[:id])
		if @ps.destroy
			flash[:notice] = "#{@ps.name} was successfully deleted."
		else
			flash[:warning] = "#{@ps.name} could not be deleted."
		end
		redirect_to(action: 'index')
	end

	def get_form
		@ps = PicklistSpecification.new(format: params[:format])
		@tm = @ps.init_tm
		@tm.picklist_specification = @ps
		@ps.technical_metadata<<@tm.becomes(TechnicalMetadatum)
		@action = 'create'
		@submit_text = "Create New Picklist Specification"
		if @ps.format == "Open Reel Tape"
			@edit_mode = params[:edit_mode] == 'true'
			render(partial: 'ot', format: @format)
		else
			@formats = PhysicalObject.new.formats
			@format = @ps.format
			render(partial: 'unsupported_format')
		end
	end

	def ot_hash
		{"Pack Deformation" => "", "Preservation Problems" => "" }
	end

	private
    def picklist_specification_params
      params.require(:ps).permit(:format, :name, :description)
    end

  private
  	def tm(format)
  		printf("Got format %s\n", format.nil? ? "No format" : format )
  		if format == 'Open Reel Tape'
  			OpenReelTm.new
  		end
  	end
end
