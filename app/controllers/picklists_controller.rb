class PicklistsController < ApplicationController
  before_action :set_picklist, only: [:show, :edit, :update, :destroy]
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
				@physical_objects = @physical_objects.paginate(page: params[:page])
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
		@picklisting = true
		if params[:picklist] && params[:picklist][:id]
		  redirect_to pack_list_picklist_path(params[:picklist][:id], box_id: params[:box_id], bin_id: params[:bin_id])
		elsif params[:id]
			@picklist = Picklist.find(params[:id])
			if params[:search_button]
				@physical_object = PhysicalObject.where("picklist_id = ? and call_number = ?", @picklist.id, params[:call_number]).packing_sort.first
				if @physical_object.nil?
				  flash[:warning] = "No matching items found.  Loading first packable item on picklist (if applicable), instead."
				  @physical_object = PhysicalObject.packable_on_picklist(@picklist.id, nil).packing_sort.first
				else
				  flash[:notice] = "First matching item loaded."
				end
			elsif params[:physical_object]
				@physical_object = PhysicalObject.find(params[:physical_object][:id])
			else
				#@physical_object = PhysicalObject.where("picklist_id = ? and box_id is null and bin_id is null", @picklist.id).packing_sort.first
				@physical_object = PhysicalObject.packable_on_picklist(@picklist.id, nil).packing_sort.first
			end	
			if @physical_object
				@tm = @physical_object.technical_metadatum.as_technical_metadatum
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
				@box = Box.find(params[:box_id])
			elsif params[:box_mdpi_barcode]
				@box = Box.where("mdpi_barcode = ?", params[:box_mdpi_barcode]).first
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
			elsif params[:manual_pack_button]
				pack_manual
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
      			@tm = @physical_object.technical_metadatum.as_technical_metadatum
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
      			@tm = @physical_object.technical_metadatum.as_technical_metadatum
			# need to recalculate the bookend physical objects
			surrounding_physical_objects
		end

		# called while packing a picklist (in physical object view mode) to mark the current physical object as packed (with the provided bin/box barcodes)
		def pack
			# lookup the values passed for box_mdpi_barcode and bin_mdpi_barcode
			if updated?
				if ApplicationHelper.assigned_real_barcode?(@physical_object)
					if @physical_object.workflow_blocked?
						@physical_object.errors[:condition_statuses] = "- One or more active Condition Statuses prevent the packing of this record.".html_safe
						render 'pack_list'
					else
						if @bin
							@physical_object.bin = @bin
						end
						if @box
							@physical_object.box = @box
						end
						@physical_object.save
						#FIXME: make this more efficient by combining with surrounding_physical_objects?
						@physical_object = PhysicalObject.packable_on_picklist(@picklist.id, nil).where("call_number > ? or (call_number = ? and (group_key_id > ? or (group_key_id = ? and (group_position > ? or (group_position = ? and id > ?)))))", @physical_object.call_number, @physical_object.call_number, @physical_object.group_key_id, @physical_object.group_key_id, @physical_object.group_position, @physical_object.group_position, @physical_object.id).packing_sort.first
						if @physical_object
						  @tm = @physical_object.technical_metadatum.as_technical_metadatum
						  surrounding_physical_objects
						else
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
		  @physical_objects = PhysicalObject.includes(:group_key).where("picklist_id = ?", @picklist.id).references(:group_key).order("call_number", "group_keys.id", "group_position", "physical_objects.id")
		end

		def set_counts
                  @packed_count = PhysicalObject.where("picklist_id = ? and (bin_id is not null or box_id is not null)", @picklist.id).count
                  @total_count = PhysicalObject.where("picklist_id = ? and (bin_id is null and box_id is null)", @picklist.id).count
                  @blocked = PhysicalObject.find_by_sql("
                    select physical_objects.*
                    from physical_objects, condition_statuses, condition_status_templates
                    where condition_statuses.physical_object_id = physical_objects.id
                      and condition_statuses.condition_status_template_id = condition_status_templates.id
                      and condition_statuses.active = true
                      and condition_status_templates.blocks_packing = true
                      and physical_objects.picklist_id = #{@picklist.id}")
		end

		def picklist_params
			params.require(:picklist).permit(:name, :description, :destination, :complete)
		end

		def set_container(physical_object, box, bin)
			if (box or bin)
				PhysicalObject.transaction do
					physical_object.update_attributes(bin_id: (bin.nil? ? 0 : bin.id), box_id: (box.nil? ? 0 : box.id))
					# workflow status automatically updated
				end
			else
				return false
			end
		end

		def surrounding_physical_objects
			unless @physical_object.nil?
				# find immediate neighbors
				all_candidates = PhysicalObject.where(picklist_id: @picklist.id).packing_sort
				if all_candidates.any?
				  index = all_candidates.find_index {|p| p.id == @physical_object.id}
				  @previous_physical_object = all_candidates[index - 1]
				  @wrap_previous = ((index - 1) < 0)
				  @next_physical_object = all_candidates[(index + 1) < all_candidates.size ? index + 1 : 0]
				  @wrap_next = ((index + 1) >= all_candidates.size)
				end

				# find surrounding packable neighbors
                                packable_candidates = PhysicalObject.packable_on_picklist(@picklist.id, @physical_object.id).packing_sort
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
        update = @tm.update_attributes(tm_params)
      end
      return updated
		end
	
end
