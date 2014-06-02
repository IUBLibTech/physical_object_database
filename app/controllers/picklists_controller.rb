class PicklistsController < ApplicationController
  before_action :set_picklist, only: [:show, :edit, :update, :destroy]

	def new
		@picklist = Picklist.new
		@edit_mode = true
		@submit_text = "Create Picklist"
		@action = 'create'
	end

	def create
		@picklist = Picklist.new(picklist_params)
		@edit_mode = true
		@submit_text = "Create Picklist"
		@action = 'create'
		if @picklist.save
			flash[:notice] = "Successfully created #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: "index")
		else
			render('new')
		end
	end

	def show
		@edit_mode = false

		respond_to do |format|
			format.html
			format.csv { send_data PhysicalObject.to_csv(@physical_objects) }
			format.xls
		end
	end

	def edit
		@edit_mode = true
		@action = 'update'
		@submit_text = "Update Picklist"
	end

	def update
		if Picklist.where("id != ? AND name=?", @picklist.id, params[:picklist][:name]).size > 0
			flash[:notice] = "There is another picklist with name #{params[:picklist][:name]}."
			@edit_mode = true
			@action = 'update'
			@submit_text = "Update Picklist"
			render('edit')
		elsif @picklist.update_attributes(picklist_params)
			flash[:notice] = "Successfully updated #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')	
		else
			render('edit')
		end
	end

	def destroy
		if @picklist.destroy
			PhysicalObject.update_all("picklist_id = NULL", "picklist_id = #{@picklist.id}")
			flash[:notice] = "Successfully deleted #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')
		else
			flash[:notice] = "Unable to delete #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')
		end		
	end

	def process_list
		@picklist = Picklist.find(params[:picklist][:id])
		@action = "assign_to_container"
		if params[:box_id]
			@box = Box.find(params[:box_id])
		end
		if params[:bin_id]
			@bin = Bin.find(params[:bin_id])
		end
		@tm = @picklist.physical_objects.size > 0 ? @picklist.physical_objects[0].technical_metadatum.as_technical_metadatum : nil
	end

	def assign_to_container
		PhysicalObject.transaction do
			physical_object = PhysicalObject.find(params[:physical_object][:id])
			if (params[:box] and params[:box][:id])
				box = Box.find(params[:box][:id])
				physical_object.box = box;
				template = WorkflowStatusTemplate.where(name: "Boxed")[0]
				status = WorkflowStatus.new(physical_object_id: physical_object.id, workflow_status_template_id: template.id)
				physical_object.workflow_statuses << status
				physical_object.box_id = box.id
				physical_object.save
			end
		end
		redirect_to(action: 'process_list', picklist: {id: params[:id]}, box: {id: params[:box][:id]})
	end

	

	private
		def set_picklist
		  #special case: picklist_ is spoofed into id value for nice CSV/XLS filenames
		  if request.format.csv? || request.format.xls?
	 	    params[:id] = params[:id].sub(/picklist_/, '')
		  end
		  @picklist = Picklist.find(params[:id])
		  @physical_objects = @picklist.physical_objects
		end
		def picklist_params
			params.require(:picklist).permit(:name, :description)
		end

end
