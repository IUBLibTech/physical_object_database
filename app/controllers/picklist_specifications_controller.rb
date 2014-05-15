class PicklistSpecificationsController < ApplicationController

	def index
		@picklist_specs = PicklistSpecification.all
		@picklists = Picklist.all
	end

	def new
		@formats = PhysicalObject.formats
		@edit_mode = true
		@ps = PicklistSpecification.new(id: 0, format: "CD-R")
		@tm = @ps.create_tm
		@action = 'create'
		@submit_text = "Create New Picklist Specification"
	end

	def create
		@ps = PicklistSpecification.new(picklist_specification_params)
		@tm = @ps.create_tm
		@tm.picklist_specification = @ps;
		@tm.update_attributes(tm_params)
		
		redirect_to(action: 'index')
	end

	def edit
		@ps = PicklistSpecification.find(params[:id])
		@tm = @ps.technical_metadatum.as_technical_metadatum
		@edit_mode = true
		@action = 'update'
		@submit_text = "Update Picklist Specification"
	end

	def update
		@ps = PicklistSpecification.find(params[:id])
		if (@ps.update_attributes(picklist_specification_params))
			@tm = @ps.technical_metadatum.as_technical_metadatum
			@tm.update_attributes(tm_params)
			flash[:notice] = "#{@ps.name} successfully updated."
		else
			flash[:notice] = "Failed to update #{@ps.name}."
		end
		redirect_to(action: 'index')
	end

	def show
		@ps = PicklistSpecification.find(params[:id])
		@tm = @ps.technical_metadatum.as_technical_metadatum
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

	def query
		@ps = PicklistSpecification.find(params[:id])
		@picklists = Picklist.find(:all, order: 'name').collect{|p| [p.name, p.id]}
		po = PhysicalObject.new(format: @ps.format)
		po.technical_metadatum = @ps.technical_metadatum

		@physical_objects = po.physical_object_query
		flash[:notice] = "Results for #{@ps.name}"
	
		@edit_mode = true
		@action = 'query_add'
		@submit_text = "Add Selected Objects to Picklist"
	end

	def query_add
		@picklist = Picklist.find(params[:picklist][:id])
		
		unless params[:po_ids].nil?
				params[:po_ids].each do |po|
				PhysicalObject.find(po).update_attributes(picklist_id: @picklist.id)
			end
		end
		
		redirect_to(action: 'query', id: params[:id])
	end

  private
    def picklist_specification_params
      params.require(:ps).permit(:format, :name, :description)
    end


	def format_tm_where(tm)
		q = ""
		stm = tm.as_technical_metadatum
		stm.attributes.each do |name, value|
			if name == 'id' or name == 'created_at' or name == 'updated_at'
				next
			else
				if !value.nil? and value.length > 0
					q << " AND open_reel_tms.#{name}='#{value}'"
				end
			end
		end
		q
	end
	
end
