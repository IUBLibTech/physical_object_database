class PicklistSpecificationController < ApplicationController

	def index
		@picklists = PicklistSpecification.all
	end

	def new
		@formats = PhysicalObject.new.formats
		@ps = PicklistSpecification.new(format: params[:format])
	end

	def create
		@ps = PicklistSpecification.new
		@ps.fields = params[:ps][:fields]
		@ps.update_attributes(picklist_specification_params)
		redirect_to(action: 'index')
	end

	def edit

	end

	def update
		
	end

	def show
		@ps = PicklistSpecification.find(params[:id])
		@tm = tm(@ps.format)
	end

	def delete

	end

	def destroy
		
	end

	def get_form
		@ps = PicklistSpecification.new(format: params[:format])
		@ps.init_tm
		if @ps.format == "Open Reel Tape"
			@tm.picklist_specification = @ps
			puts("***********************************\n")
			printf("WTF: %s\n", @tm)
			puts("***********************************\n")
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
      params.require(:ps).permit(:format, :name, :description, :fields)
    end

  private
  	def tm(format)
  		printf("Got format %s\n", format.nil? ? "No format" : format )
  		if format == 'Open Reel Tape'
  			OpenReelTm.new
  		end
  	end

end
