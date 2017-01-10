class PicklistsController < ApplicationController
	before_action :set_picklist, only: [:show, :edit, :update, :destroy, :resend]
	before_action :authorize_collection, only: [:index, :new, :create, :pack_list]
	before_action :set_counts, only: [:show, :edit]
  # before_action :set_packing_picklist, only: :pack_list

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
			format.html do
				@physical_objects = @physical_objects.eager_load(:group_key).paginate(page: params[:page])
			end
			format.csv { send_data PhysicalObject.to_csv(@physical_objects, @picklist) }
			format.xls
		end
	end

	def edit
		@edit_mode = true
		@action = 'update'
		@submit_text = "Update Picklist"
		respond_to do |format|
			format.html { @physical_objects = @physical_objects.paginate(page: params[:page]) }
		end
	end

	def update
		if @picklist.update_attributes(picklist_params)
			flash[:notice] = "Successfully updated #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')	
		else
			@edit_mode = true
			@action = 'update'
			@submit_text = "Update Picklist"
			set_counts
			@physical_objects = @physical_objects.paginate(page: params[:page])
			render(action: :edit)
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

	# pack list can be reached in the following ways
	# 1) from auto packing a bin - bin_id will be present
  # 2) from auto packing a box - box_id will be present
	# 3) from manually packing a pick list - only picklist_id will be present
	# 4) after packing a physical object - the physical object id, 'pack', bin and/or box id (as hidden attributes) will be present
	# 5) after unpacking a physical object - the physical object id, 'unpack', bin and/or box id (as hidden attributes) will also be present
	# 5) after moving to previous physical object - picklist id, physical object id, bin/box id (as hidden attributes) will be present
	# 6) after moving to the next physical object - picklist id, physical object id, bin/box id (as hidden attributes) will be present
def pack_list
	@display_assigned = false
	@edit_mode = true
	@pack_mode = true
	@picklisting = true
	if params[:picklist] && params[:picklist][:id]
		redirect_to pack_list_picklist_path(params[:picklist][:id], box_id: params[:box_id], bin_id: params[:bin_id])
	elsif params[:id]
		@picklist = Picklist.eager_load(:physical_objects).find(params[:id])
		authorize @picklist
		if params[:search_button]
			@physical_object = PhysicalObject.eager_load(:group_key, :bin, :box, :unit).where("picklist_id = ? and call_number = ?", @picklist.id, params[:call_number]).packing_sort.first
			if @physical_object.nil?
				flash[:warning] = "No matching items found.  Loading first packable item on picklist (if applicable), instead."
				@physical_object = @picklist.physical_objects.unpacked.packing_sort.first
			else
				flash[:notice] = "First matching item loaded."
			end
		elsif params[:physical_object]
			@physical_object = PhysicalObject.eager_load(:group_key, :bin, :box, :unit).find(params[:physical_object][:id])
		else
			@physical_object = @picklist.physical_objects.unpacked.packing_sort.first
		end	
		if @physical_object
			@tm = @physical_object.technical_metadatum.specific
			@group_key = @physical_object.group_key
			surrounding_physical_objects
		end
		if params[:bin_id]
			@bin = Bin.find(params[:bin_id])
		elsif params[:bin_mdpi_barcode]
			@bin = Bin.where("mdpi_barcode = ?", params[:bin_mdpi_barcode]).first
		end
		if @bin and @bin.workflow_statuses.last.past_status?("Created")
			flash[:warning] = "The current workflow status of Bin <i>#{@bin.identifier}</i> is #{@bin.current_workflow_status}. It cannot be packed.".html_safe
			render 'pack_list'
			return
		end

		if params[:box_id]
			@box = Box.eager_load(:physical_objects).find(params[:box_id])
		elsif params[:box_mdpi_barcode]
			@box = Box.where("boxes.mdpi_barcode = ?", params[:box_mdpi_barcode]).eager_load(:physical_objects).first
		end
		if @box and @box.full?
			flash[:warning] = "Box #{@box.mdpi_barcode} is full. It cannot be packed.".html_safe
			render 'pack_list'
			return
		end
		if params[:pack_bin_button]
			pack_bin
		elsif params[:pack_box_button]
			pack_box
		elsif params[:pack_button]
			pack
		elsif params[:unpack_button]
			unpack
		elsif params[:previous_button]
			previous_po	
		elsif params[:next_button]
			next_po
		elsif params[:previous_unpacked_button]
			previous_po(true)
		elsif params[:next_unpacked_button]
			next_po(true)
		end
	else
		flash[:warning] = "A valid Pick List ID was not specified.".html_safe
		redirect_to picklist_specifications_path 
	end
	if @picklist
			# handles both pack of last item and upack of a fully packed pick list
			@picklist.update(complete: @picklist.all_packed?)
		end
	end

	def resend
		if @picklist.physical_objects.all? { |po| po.apply_resend_status }
			flash[:notice] = 'All objects were successfuly marked for resending to Memnon.'
                else
			flash[:warning] = 'One or more objects failed!'
                end
		redirect_to :back
	end

	private
		# called when a bin object's pack button is clicked
		def pack_bin
			if @bin.workflow_statuses.last.past_status?("Created")
				flash[:warning] = "#{@bin.identifier} cannot be packed. Its current status is #{@bin.current_workflow_status}".html_safe
				redirect_to :back
			end
		end

		# called when a box object's pack button is clicked
		def pack_box
			if @box.full?
				flash[:warning] = "Box #{@box.mdpi_barcode} is full. Cannot pack more physical objects".html_safe
				redirect_to :back
			end	
		end

		# called while packing a picklist (in physical object view mode) to skip to the next physical object in the pick list
		def next_po(unpacked_flag = false)
			if (@wrap_next && !unpacked_flag) || (@wrap_next_packable && unpacked_flag)
				flash[:notice] = "Wrapped around start of picklist."
			else
				flash[:notice] = ""
			end
			unless updated?
				render 'pack_list'
			end
			@physical_object.save
			if unpacked_flag
				@physical_object = @next_packable_physical_object
			else
				@physical_object = @next_physical_object
			end
			@tm = @physical_object.technical_metadatum.specific
			@group_key = @physical_object.group_key
      			# need to recalculate bookend physical objects
      			surrounding_physical_objects
      		end

		# called while packing a picklist (in physical object view mode) to move to the previous physical object in the picklist
		def previous_po(unpacked_flag = false)
			if (@wrap_previous && !unpacked_flag) || (@wrap_previous_packable && unpacked_flag)
				flash[:notice] = "Wrapped around end of picklist."
			else
				flash[:notice] = ""
			end
			unless updated?
				render 'pack_list'
			end
			@physical_object.save
			if unpacked_flag
				@physical_object = @previous_packable_physical_object
			else
				@physical_object = @previous_physical_object
			end
			@tm = @physical_object.technical_metadatum.specific
			@group_key = @physical_object.group_key
			# need to recalculate the bookend physical objects
			surrounding_physical_objects
		end

		# called while packing a picklist (in physical object view mode) to mark the current physical object as packed (with the provided bin/box barcodes)
		def pack
			# lookup the values passed for box_mdpi_barcode and bin_mdpi_barcode
			if updated?
				if ApplicationHelper.real_barcode?(@physical_object.mdpi_barcode)
					if @physical_object.workflow_blocked?
						@physical_object.errors[:condition_statuses] = "- One or more active Condition Statuses prevent the packing of this record.".html_safe
						render 'pack_list'
					elsif @bin.nil? && @box.nil?
						flash[:warning] = "You must assign a valid bin or box barcode in order to pack this item.  Physical object not saved."
						render 'pack_list'
					else
						if @bin
							@physical_object.bin = @bin
						end
						if @box
							@physical_object.box = @box
						end
						if @physical_object.save
						  # catch edge case: final unpacked physical object was just packed
						  original_object = @physical_object
						  surrounding_physical_objects
						  if @next_packable_physical_object == original_object && @previous_packable_physical_object == original_object
						    @physical_object = nil
						  else
						    @physical_object = @next_physical_object
						  end

						  if @physical_object
						  	@tm = @physical_object.technical_metadatum.specific
						  	@group_key = @physical_object.group_key
						  	surrounding_physical_objects
						  end
						else
							flash[:warning] = "Unable to save physical object: #{@physical_object.errors.full_messages}"
							if @bin && @box
								@bin = nil
								@box = nil
							end
							render 'pack_list'
						end
					end
				else
					@physical_object.errors[:mdpi_barcode] = "- Must assign a valid MDPI barcode to pack a Physical Object".html_safe
					render 'pack_list'
				end
			end
		end

		# called while packing a picklist (in physical object view mode) to mark the current physical object as unpacked
		def unpack
			# stay on the same object?
			if updated?
				@physical_object.bin = nil
				@physical_object.box = nil
				@physical_object.save
			end
			# @physical_object = @next_physical_object
			# surrounding_physical_objects
		end

		def set_picklist
			if request.format.csv? || request.format.xls?
		    # special case: picklist_ is spoofed into id value for nice CSV/XLS filenames
		    params[:id] = params[:id].sub(/picklist_/, '')
		  end
		  @picklist = Picklist.eager_load(:physical_objects).where("picklists.id = ?", params[:id]).first
		  authorize @picklist
		  @physical_objects = PhysicalObject.eager_load(:group_key).where("picklist_id = ?", @picklist.id).references(:group_key).packing_sort
		end

		def authorize_collection
			authorize Picklist
		end

		def set_counts
			@total_count = @physical_objects.size
			@packed_count = @physical_objects.packed.size
			@blocked = @physical_objects.unpacked.blocked
			@blocked_count = @blocked.size
			@unpacked_count = @total_count - @packed_count
			@packable_count = @unpacked_count - @blocked_count
		end

		def picklist_params
			params.require(:picklist).permit(:name, :description, :destination, :complete, :format, :shipment_id, :shipment)
		end

		def surrounding_physical_objects
			unless @physical_object.nil?
				# find immediate neighbors
				all_candidates = @picklist.physical_objects.packing_sort
				if all_candidates.any?
					index = all_candidates.find_index {|p| p.id == @physical_object.id}
					@previous_physical_object = all_candidates[index - 1]
					@wrap_previous = ((index - 1) < 0)
					@next_physical_object = all_candidates[(index + 1) < all_candidates.size ? index + 1 : 0]
					@wrap_next = ((index + 1) >= all_candidates.size)
				end

				# find surrounding packable neighbors
				packable_candidates = @picklist.physical_objects.unpacked_or_id(@physical_object.id).packing_sort
				if packable_candidates.any?
					index = packable_candidates.find_index {|p| p.id == @physical_object.id}
					@previous_packable_physical_object = packable_candidates[index - 1]
					@wrap_previous_packable = ((index - 1 ) < 0)
					@next_packable_physical_object = packable_candidates[(index + 1) < packable_candidates.size ? index + 1 : 0]
					@wrap_next_packable = ((index + 1) >= packable_candidates.size)
				end
			end
		end

		def updated?
			updated = @physical_object.update_attributes(physical_object_params)
			if updated
				@tm = @physical_object.technical_metadatum.specific
				update = @tm.update_attributes(tm_params)
			end
			return updated
		end

	end
