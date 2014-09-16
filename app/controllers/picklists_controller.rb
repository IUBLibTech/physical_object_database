class PicklistsController < ApplicationController
  before_action :set_picklist, only: [:show, :edit, :update, :destroy, :process_list]

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
		#@action = 'show'

		respond_to do |format|
			format.html
			format.csv { send_data PhysicalObject.to_csv(@physical_objects, @picklist) }
			format.xls
		end
	end

	def edit
		@edit_mode = true
		@action = 'update'
		@submit_text = "Update Picklist"
	end

	def update
		#FIXME: do we need this manual check?  Just add it as a model validation?
		if Picklist.where("id != ? AND name=?", @picklist.id, params[:picklist][:name]).size > 0 && false
			flash[:notice] = "There is another picklist with name #{params[:picklist][:name]}."
			@edit_mode = true
			@action = 'update'
			@submit_text = "Update Picklist"
			render('edit')
		elsif @picklist.update_attributes(picklist_params)
			flash[:notice] = "Successfully updated #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')	
		else
			@edit_mode = true
			@action = 'update'
			@submit_text = "Update Picklist"
			render(action: :edit)
			#render('edit')
		end
	end

	def destroy
		if @picklist.destroy
			#manually dissociate physical objects
			PhysicalObject.where(picklist_id: @picklist.id).update_all(picklist_id: nil)
			flash[:notice] = "Successfully deleted #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')
		else
			flash[:notice] = "Unable to delete #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')
		end		
	end

	def process_list
		# box_id or bin_id will be present if the form is "auto" populating - in which case the view will create a
		# hidden field for the box/bin and its id attribute
		@box = (params[:box_id] and params[:box_id].length > 0) ? Box.find(params[:box_id]) : nil
		@bin = (params[:bin_id] and params[:bin_id].length > 0) ? Bin.find(params[:bin_id]) : nil
	end

	#FIXME: BUG: if multiple bins have "0" as their mdpi_barcode
	def assign_to_container
		physical_object = PhysicalObject.find(params[:po_id])
		physical_object.mdpi_barcode = params[:physical_object][:mdpi_barcode]
		physical_object.has_ephemera = params[:physical_object][:has_ephemera]
		
		po_barcode = params[:physical_object][:mdpi_barcode]
		# the return value from barcode_assigned is either false (if unassigned) or the object to which it is assigned
		assigned = ApplicationHelper.barcode_assigned?(po_barcode)

		# hidden input values will be present if the packing context is a bin or box
		@box = (!params[:box_id].nil? and params[:box_id].length > 0) ? Box.find(params[:box_id]) : nil		
		@bin = (!params[:bin_id].nil? and params[:bin_id].length > 0) ? Bin.find(params[:bin_id]) : nil
		# or in manual mode, the user specifies these in the visible input fields
		box = !params[:box_barcode].nil? ? Box.where(mdpi_barcode: params[:box_barcode])[0] : nil
		bin = !params[:bin_barcode].nil? ? Bin.where(mdpi_barcode: params[:bin_barcode])[0] : nil
		#Need to finish the TM view fro LPs in the picklist processing screendebugger
		error_msg = nil
		# you must have a container to put a physical object into		
		if (@box.nil? and @bin.nil?) and (box.nil? and bin.nil?) 
			error_msg = "<b class='warning'>An existing Bin and/or Box barcode must be specified.</b>".html_safe
		elsif (@box.nil? and !box.nil? and box.mdpi_barcode == "0") or (@bin.nil? and !bin.nil? and bin.mdpi_barcode == "0")
			error_msg = "<b class='warning'>You may not specify an MDPI Barcode of 0 for a Bin or Box.</b>".html_safe
		# physical objects can't be packed without a valid MDPI barcode
		elsif !ApplicationHelper.valid_barcode?(po_barcode) or po_barcode == "0"
			error_msg = "<b class='warning'>Invalid MDPI Barcode: #{po_barcode}</b>".html_safe
		# valid barcode can't have already been assigned to another physical object
		elsif assigned and assigned != physical_object
			error_msg = "<b class='warning'>Barcode: #{po_barcode} has already been assigned to another #{assigned.class.name.underscore.humanize}</b>".html_safe
		# packing a box but the hidden box id and the form provided box mdpi barcode don't match up
		elsif !@box.nil? and params[:box_barcode].to_i != @box.mdpi_barcode
			error_msg = "<b class='warning'>Attempt to assign a different box barcode from the packing box. Physical Object has not been packed!</b>".html_safe
		# packing a bin but the hidden bin id and the form provided bin barcode do not match up
		elsif !@bin.nil? and params[:bin_barcode].to_i != @bin.mdpi_barcode
			error_msg = "<b class='warning'>Attmempt to assign a different bin barcode from the packing bin. Physical Object has not been packed!</b>".html_safe
		end

		PhysicalObject.transaction do
			# determine what gets pass into the set_container method - the hidden form box parameters, or the visible user parameters
			@box = @box.nil? ? box : @box
			@bin = @bin.nil? ? bin : @bin
			if error_msg.nil? and set_container(physical_object, @box, @bin)
				render(partial: "picklist_physical_object_form", locals: {p: physical_object, index: 0, box: @box, bin: @bin})
			else
				render(partial: "/ajax_error/ajax_error_popup", status: 422, locals: {message: (error_msg.nil? ? "<b class='warning'>Failed to update the Physical Object...</b>".html_safe : error_msg)})	
			end
		end
	end

	def remove_from_container
		Picklist.transaction do
			physical_object = PhysicalObject.find(params[:po_id])
			box_id = params[:box_id] ? params[:box_id] : nil
			bin_id = params[:bin_id] ? params[:bin_id] : nil
			box = box_id.nil? ? nil : Box.find(box_id)
			bin = bin_id.nil? ? nil : Bin.find(bin_id)
			# remove the physical object from ALL containers it has been associated with
			if physical_object.box or physical_object.bin
				physical_object.box = nil
				physical_object.bin = nil
				stat = WorkflowStatusQueryModule.new_status(physical_object, "Barcoded")
				stat.save
			end			
			if physical_object.save
				render(partial: "picklist_physical_object_form", locals: {p: physical_object, box: box, bin: bin, index: 0})
			else
				render(partial: "/ajax_error/ajax_error_popup", status: 422, locals: {message: (error_msg.nil? ? "<b class='warning'>An error occured while trying to update the Physical Object...</b>".html_safe : error_msg)})
			end
		end
	end

	def container_full
		bin = params[:bin_id].nil? ? nil : Bin.find(params[:bin_id])
		box = params[:box_id].nil? ? nil : Box.find(params[:box_id])
		
		# it's also possible for the form to submit a bin barcode when marking a box as packed
		if !bin and params[:bin_barcode] and params[:bin_barcode].length > 0
			bin = Bin.where(mdpi_barcode: params[:bin_barcode])[0]
		end

		# use cases - box without a bin/box with bin/no box, just bin
		Picklist.transaction do
			if bin and !box
				bin.current_workflow_status = "Packed"
				bin.save
			elsif box and bin
				box.bin = bin
				box.save
				PhysicalObject.where(box_id: box.id).update_all(bin_id: bin.id)
			elsif box
				# there is no workflow status currently for boxes so in this case there is nothing to do... yet
			else
				flash[:notice] = "<b class='warning'>Could not find a Bin with barcode: '<i>#{params[:bin_barcode]}</i>'</b>".html_safe
				redirect_to(action: 'process_list', picklist: {id: params[:id]}, box_id: box.id)
				return	
			end
			redirect_to(bins_path)
		end
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

		def set_container(physical_object, box, bin)
			PhysicalObject.transaction do
				physical_object.update_attributes(bin_id: (bin.nil? ? 0 : bin.id), box_id: (box.nil? ? 0 : box.id))
				template = WorkflowStatusTemplate.where(name: (bin.nil? ? "Boxed" : "Binned"))[0]
				status = WorkflowStatus.new(physical_object_id: physical_object.id, workflow_status_template_id: template.id)
				return status.save
			end
		end
end
