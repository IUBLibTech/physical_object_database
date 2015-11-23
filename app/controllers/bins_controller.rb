class BinsController < ApplicationController
  before_action :set_bin, only: [:show, :edit, :update, :destroy, :unbatch, :seal, :unseal, :show_boxes, :assign_boxes, :workflow_history]
  before_action :authorize_collection, only: [:index, :new, :create]
  before_action :set_assigned_boxes, only: [:show, :assign_boxes]
  before_action :set_unassigned_boxes, only: [:index, :show_boxes]

	def index
		@bins = Bin.eager_load([:physical_objects, :boxes]).all
    @bins = @bins.where(workflow_status: params[:workflow_status]) unless params[:workflow_status].blank?
    @bins = @bins.where(format: params[:format]) unless params[:format].blank?
	end

	def new
		@bin = Bin.new(mdpi_barcode: 0)
		@batches = Batch.all.order('identifier').collect{|b| [b.identifier, b.id]}
	end

	def create
		@bin = Bin.new(bin_params)
		@batches = Batch.all.order('identifier').collect{|b| [b.identifier, b.id]}
		assign_batch(params, @bin)
		if @bin.save
			flash[:notice] = "<b>#{@bin.identifier}</b> was successfully created.".html_safe
			redirect_to(:action => 'index')
		else
			render('new')
		end
	end

	def edit
		@batches = Batch.all.order('identifier').collect{|b| [b.identifier, b.id]}
	end

	def update
		Bin.transaction do
			@batches = Batch.all.order('identifier').collect{|b| [b.identifier, b.id]}
			assign_batch(params, @bin)
			if @bin.update_attributes(bin_params)

				flash[:notice] = "Successfully updated <i>#{@bin.identifier}</i>.".html_safe
				redirect_to(:action => 'show', :id => @bin.id)
			else
				@edit_mode = true
				render action: :edit
			end
		end
	end

	def show
		if @boxes.any?
		  @physical_objects = PhysicalObject.includes(:group_key).where(box_id: @boxes.map { |box| box.id }).references(:group_key).packing_sort
		else
		  @physical_objects = PhysicalObject.includes(:group_key).where(bin_id: @bin.id).references(:group_key).packing_sort
		end
		@picklists = Picklist.where("complete = false").order('name').collect{|p| [p.name, p.id]}
		@edit_mode = false
		if request.format.html?
		  @physical_objects = @physical_objects.paginate(page: params[:page])
		end
	end

	def destroy
		if @bin.destroy
			flash[:notice] = "<i>#{@bin.identifier}</i> was successfully destroyed.".html_safe
			redirect_to bins_path
		else
			flash[:notice] = "<b>Failed to delete this Bin</b>".html_safe
			render('show')
		end
	end

	def workflow_history
		@workflow_statuses = @bin.workflow_statuses
	end

	def add_barcode_item
		bc = params[:barcode][:mdpi_barcode]
		@bin = Bin.find(params[:bin][:id])
		@physical_objects = @bin.physical_objects
		if Box.where(mdpi_barcode: bc).where("mdpi_barcode != ?", 0).limit(1).size == 1
			box = Box.where(mdpi_barcode: bc).first
			box.bin = @bin
			box.save
			flash[:notice] = "Successfully added Box <i>#{box.mdpi_barcode}</i> to the Bin.".html_safe
		elsif PhysicalObject.where(mdpi_barcode: bc).where("mdpi_barcode != ?", 0).limit(1).size == 1
			po = PhysicalObject.where(mdpi_barcode: bc).first
			po.bin = @bin
			po.save
			flash[:notice] = "Successfully added Physical Object <i>#{po.mdpi_barcode}</i> to Bin #{@bin.identifier}.".html_safe
		else
			@box = Box.new
			@box.mdpi_barcode = bc
			@box.bin = @bin
			#TODO: for now, boxes cannot be assigned a barcode of 0 even though it is technically valid. This will change
			#at some point but is yet to be decided the workflow behavior
			
			if bc != '0' and @box.save
				flash[:notice] = "Successfully created new Box <i>#{bc}</i> and added it to Bin <i>#{@bin.identifier}</i>".html_safe
			else 
				#don't redirect because view needs @box to display error messages
				@bin.errors.add(:boxes, "tried to add/create a  Box with invalid MDPI barcode: #{bc}")
				render('show')
				return
			end
		end
		redirect_to(action: 'show', id: @bin.id)
	end

	def unbatch
		@bin.batch = nil
		if @bin.save
		  flash[:notice] = "Successfully removed Bin <i>#{@bin.identifier}</i> from Batch <i>#{@batch.identifier}</i>.".html_safe
		else
		  flash[:notice] = "<b class='warning'>Failed to remove this Bin from Batch.</b>".html_safe
		end
                redirect_to :back
	end

	def seal
		if @bin.current_workflow_status == "Created"
			@bin.current_workflow_status = "Sealed"
			@bin.save
			flash[:notice] = "Bin <i>#{@bin.identifier}</i> was marked as Sealed.".html_safe
		else 
			flash[:warning] = "Cannot Seal Bin <i>#{@bin.identifier}</i>. It's current workflow status is already #{@bin.current_workflow_status}"
		end
		redirect_to bin_path
	end

	def unseal
	  case @bin.current_workflow_status
	  when "Created"
	    flash[:notice] = "Bin was already unsealed.  No action taken."
	  when "Sealed"
	    @bin.current_workflow_status = "Created"
	    if @bin.save and @bin.current_workflow_status == "Created"
	      flash[:notice] = "Bin workflow status has been successfully reset to Created."
	    else
	      flash[:notice] = "<b class='warning'>There was a problem unsealing the Bin.</b>".html_safe
	    end
	  when "Batched"
	    flash[:notice] = "<b class='warning'>The Bin must be unbatched before it can be unsealed.</b>".html_safe
	  else # Returned, Complete
	    flash[:notice] = "<b class='warning'>Unsealing the bin is not applicable to this workflow status.</b>".html_safe
	  end
	  redirect_to bin_path
	end

	def show_boxes
		if @bin.packed_status?
		  flash[:warning] = Bin.packed_status_message
		  redirect_to action: :show
                elsif @bin.physical_objects.any?
                  flash[:warning] = Bin.invalid_box_assignment_message
                  redirect_to action: :show
		end
	end

	def assign_boxes
                if @bin.packed_status?
                  flash[:warning] = Bin.packed_status_message
                  redirect_to action: :show
		  return
                elsif @bin.physical_objects.any?
                  flash[:warning] = Bin.invalid_box_assignment_message
                  redirect_to action: :show
                  return
                end
		unless params[:box_ids].nil?
			params[:box_ids].each do |b_id|
				Box.find(b_id).update_attributes(bin_id: @bin.id)
			end
		end
		redirect_to(bin_path(@bin.id))
	end

	private
	def set_bin
		@bin = Bin.find(params[:id])
		authorize @bin
		@batch = @bin.batch
	end

	def authorize_collection
		authorize Bin
	end

	def set_assigned_boxes
		@boxes = @bin.boxes
	end

	def set_unassigned_boxes
		@boxes = Box.eager_load(:physical_objects).where(bin_id: [0, nil]).order(full: :desc)
	end

	def bin_index(bins, bin_id)
		bins.each_with_index { |bin, i|
			puts(bin)
			if bin[1] == bin_id
				return i
			end
		}
		0
	end

	def bin_params
		params.require(:bin).permit(:mdpi_barcode, :identifier, :description, :destination, :batch, :batch_id, :spreadsheet, 
			:spreadsheet_id, :current_workflow_status, :format,
			condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :active, :user, :_destroy])

	end

	def assign_batch(params, bin)
		if params[:batch]
			bin.batch_id = params[:batch][:id] == "" ? 0 : params[:batch][:id]
		end
	end
end
