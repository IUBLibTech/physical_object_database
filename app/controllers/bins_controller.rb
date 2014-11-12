class BinsController < ApplicationController
  before_action :set_bin, only: [:show, :edit, :update, :destroy, :unbatch, :show_boxes, :assign_boxes]

	def index
		@bins = Bin.all
		@boxes = Box.where(bin_id: [nil, 0])
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
		@boxes = @bin.boxes
		if @boxes.size > 0
			@physical_objects = Array.new
			@boxes.each do |b| 
				@physical_objects.concat(b.physical_objects)
			end
		else
			@physical_objects = @bin.physical_objects
		end
		@picklists = Picklist.all.order('name').collect{|p| [p.name, p.id]}
		@edit_mode = false
	end

	def destroy
		Bin.transaction do
			if @bin.destroy
				# we need to manually disassociate the physical objects/boxes form this bin since
				# rails will leave this column value in those tables
				PhysicalObject.where(bin_id: @bin.id).update_all(bin_id: nil)
				Box.where(bin_id: @bin.id).update_all(bin_id: nil)
				flash[:notice] = "<i>#{@bin.identifier}</i> was successfully destroyed.".html_safe
				redirect_to bins_path
			else
				flash[:notice] = "<b>Failed to delete this Bin</b>".html_safe
				render('show')
			end
		end
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

	def show_boxes
		@boxes = Box.where(bin_id: nil)
		if @bin.packed_status?
		  flash[:notice] = Box.packed_status_message
		  redirect_to action: :show
		end
	end

	def assign_boxes
                if @bin.packed_status?
                  flash[:notice] = Box.packed_status_message
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
		@batch = @bin.batch
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
		params.require(:bin).permit(:mdpi_barcode, :identifier, :description, :batch, :batch_id, :spreadsheet, 
			:spreadsheet_id, :current_workflow_status, 
			condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :active, :user, :_destroy])

	end

	def assign_batch(params, bin)
		if params[:batch]
			bin.batch_id = params[:batch][:id] == "" ? 0 : params[:batch][:id]
		end
	end
end
