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
		puts params.to_yaml
		@picklist = Picklist.find(params[:picklist][:id])
		@action = "assign_to_container"
		if params[:box_id] and params[:box_id].length > 0
			@box = Box.find(params[:box_id])
		elsif params[:bin_id] and params[:bin_id].length > 0
			@bin = Bin.find(params[:bin_id])
		else

		end
	end

	def assign_to_container
		PhysicalObject.transaction do
			physical_object = PhysicalObject.find(params[:po_id])
			po_barcode = params[:physical_object][:mdpi_barcode]
			
			# if the form was being processed from within the context of a box, a hidden attribute with that
			# box id will be passed along
			@box = (!params[:box_id].nil? and params[:box_id].length > 0) ? Box.find(params[:box_id]) : nil
			
			# if the form was being processed from within the contect of a bin, a hidden attribute with that
			# bin id will be passed along
			@bin = (!params[:bin_id].nil? and params[:bin_id].length > 0) ? Bin.find(params[:bin_id]) : nil

			# first check: see if we have a valid barcode for the physical object
			if ApplicationHelper.valid_barcode?(po_barcode) and po_barcode != "0"
				assigned = ApplicationHelper.barcode_assigned?(po_barcode)

				# second check: see if the barcode has been assigned to something else
				if assigned == false or assigned == physical_object

					# update the physical object barcode
					if params[:physical_object] and params[:physical_object][:mdpi_barcode]
						physical_object.mdpi_barcode = params[:physical_object][:mdpi_barcode]
					end
					
					# branch logic: if bin or box are not nil then we are processing within the context of some container
					if @box.nil? and @bin.nil?
						# box barcode must be present and valid

					elsif @box
						debugger
						# if the box barcode was provided and it's NOT the same as box.mdpi_barcode - error message
						if params[:box_barcode].length > 0 and params[:box_barcode].to_i != 0 and params[:box_barcode].to_i != @box.mdpi_barcode
							flash[:notice] = "<b class='warning'>Attempt to assign a different box barcode from the packing box. Physical Object has not being assigned to a box.</b>".html_safe
						else
							physical_object.box = @box;
							template = WorkflowStatusTemplate.where(name: "Boxed")[0]
							status = WorkflowStatus.new(physical_object_id: physical_object.id, workflow_status_template_id: template.id)
							physical_object.workflow_statuses << status
							physical_object.save
						end
					elsif @bin
						
					end
				else
					flash[:notice] = "<b class='warning'>Barcode: #{po_barcode} has already been assigned to another #{assigned.class.name.underscore.humanize}</b>".html_safe
				end
			else
				flash[:notice] = "<b class='warning'>Invalid MDPI Barcode: #{po_barcode}</b>".html_safe
			end
		end

		#FIXME: need to generalize this to deal with params hash containing a bin id, box id, or no id
		box_id = @box.nil? ? "" : @box.id
		bin_id = @bin.nil? ? "" : @bin.id
		redirect_to(action: 'process_list', picklist: {id: params[:id]}, box_id: box_id, bin_id: bin_id)
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
