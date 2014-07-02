class PicklistsController < ApplicationController
  before_action :set_picklist, only: [:show, :edit, :update, :destroy]

  def self.tm_to_partial(tm)
  	if tm.class == DatTm
  		"/picklists/dat_tm"
  	elsif tm.class == CdrTm 
  		"/picklists/cdr_tm"
  	elsif tm.class == OpenReelTm
  		"/picklists/open_reel_tm"
  	end
  end

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
		# box_id or bin_id will be present if the form is "auto" populating - in which case the view will create a
		# hidden field for the box/bin and its id attribute
		if params[:box_id] and params[:box_id].length > 0
			@box = Box.find(params[:box_id])
		elsif params[:bin_id] and params[:bin_id].length > 0
			@bin = Bin.find(params[:bin_id])
		# otherwise the user is manually scanning a box and/or bin barcode for the physical object
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
						physical_object.has_ephemera = params[:physical_object][:has_ephemera]
					end
					# branch logic: if bin AND box are both nil, the form was navigated to from the picklist itself and the user will
					# be providing the barcode of whatever container(s) the physical object is being packed into
					if @box.nil? and @bin.nil?
						# at least one of these must be specified
						box = Box.where(mdpi_barcode: params[:box_barcode])[0]
						bin = Bin.where(mdpi_barcode: params[:bin_barcode])[0]
						if (box.nil? and bin.nil?)
							flash[:notice] = "<b class='warning'>An existing Bin and/or Box barcode must be specified.</b>".html_safe
						else
							set_container(physical_object, box, bin)
						end
					elsif !@box.nil?
						# if the box barcode was provided and it's NOT the same as box.mdpi_barcode - error message
						if params[:box_barcode].length > 0 and params[:box_barcode].to_i != 0 and params[:box_barcode].to_i != @box.mdpi_barcode
							flash[:notice] = "<b class='warning'>Attempt to assign a different box barcode from the packing box. Physical Object has not been packed!</b>".html_safe
						else
							set_container(physical_object, @box, @bin)
						end
					elsif !@bin.nil?
						# if the bin barcode was provided and it's not the same as bin.mdpi_barcode - error
						if params[:bin_barcode].length > 0 and params[:bin_barcode].to_i != 0 and params[:bin_barcode].to_i != @bin.mdpi_barcode
							flash[:notice] = "<b class='warning'>Attmempt to assign a different bin barcode from the packing bin. Physical Object has not been packed!</b>".html_safe
						else
							set_container(physical_object, @box, @bin)
						end		
					end
				else
					flash[:notice] = "<b class='warning'>Barcode: #{po_barcode} has already been assigned to another #{assigned.class.name.underscore.humanize}</b>".html_safe
				end
			else
				flash[:notice] = "<b class='warning'>Invalid MDPI Barcode: #{po_barcode}</b>".html_safe
			end
		end

		box_id = @box.nil? ? "" : @box.id
		bin_id = @bin.nil? ? "" : @bin.id
		redirect_to(action: 'process_list', picklist: {id: params[:id]}, box_id: box_id, bin_id: bin_id)
	end



	def remove_from_container
		puts params.to_yaml
		physical_object = PhysicalObject.find(params[:po_id])
		box_id = params[:box_id] ? params[:box_id] : ""
		bin_id = params[:bin_id] ? params[:bin_id] : ""
		# remove the physical object from ALL containers it has been associated with
		if physical_object.box
			physical_object.box = nil
		end
		if physical_object.bin
			physical_object.bin = nil
		end		
		physical_object.save
		redirect_to(action: 'process_list', picklist: {id: params[:id]}, box_id: box_id, bin_id: bin_id)
	end

	def container_full
		bin = params[:bin_id].nil? ? nil : Bin.find(params[:bin_id])
		box = params[:box_id].nil? ? nil : Box.find(params[:box_id])
		
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
				status.save
			end
		end
end
