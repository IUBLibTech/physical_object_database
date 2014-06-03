class BinsController < ApplicationController
  before_action :set_bin, only: [:show, :edit, :update, :destroy, :new_box, :unbatch]

	def index
		@bins = Bin.all
		@boxes = Box.where(bin_id: [nil, 0])
	end

	def new
		@bin = Bin.new(mdpi_barcode: 0)
		@batches = Batch.find(:all, order: 'identifier').collect{|b| [b.identifier, b.id]}
	end

	def create
		@bin = Bin.new(bin_params)
		@batches = Batch.find(:all, order: 'identifier').collect{|b| [b.identifier, b.id]}
		assign_batch(params, @bin)
		if @bin.save
			flash[:notice] = "<b>#{@bin.identifier}</b> was successfully created.".html_safe
			redirect_to(:action => 'index')
		else
			render('new')
		end
	end

	def edit
		@batches = Batch.find(:all, order: 'identifier').collect{|b| [b.identifier, b.id]}
		@batch = @bin.batch
	end

	def update
		@batches = Batch.find(:all, order: 'identifier').collect{|b| [b.identifier, b.id]}
		assign_batch(params, @bin)
		if @bin.update_attributes(bin_params)
			flash[:notice] = "Successfully updated <i>#{@bin.identifier}</i>.".html_safe
			redirect_to(:action => 'show', :id => @bin.id)
		else
			@edit_mode = true
			render action: :edit
		end
	end

	def show
		@physical_objects = @bin.physical_objects
		@boxes = @bin.boxes
		@edit_mode = false
	end

	def destroy
		if @bin.destroy
			# we need to manually disassociate the physical objects/boxes form this bin since
			# rails will leave this column value in those tables
			PhysicalObject.update_all("bin_id = NULL", "bin_id = #{@bin.id}")
			Box.update_all("bin_id = NULL", "bin_id = #{@bin_id}")
			flash[:notice] = "<i>#{@bin.identifier}</i> was successfully destroyed.".html_safe
			redirect_to bins_path
		else
			flash[:notice] = "<b>Failed to delete this Bin</b>".html_safe
			render('show')
		end
	end

	def new_box	
	end

	def create_box
		bc = params[:barcode][:mdpi_barcode]
		if barcode_assigned(bc)
			flash[:notice] = '<b class="warning">#{bc} has already been assigned to another object</b>'
		else

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
	     flash[:notice] = "<em>Successfully removed Bin from Batch.</em>".html_safe
	   else
	     flash[:notice] = "<strong>Failed to remove this Bin from Batch.</strong>".html_safe
	   end
	   unless @batch.nil?
	     redirect_to @batch
	   else
	     redirect_to @bin
	   end
	end

	private
	def set_bin
		@bin = Bin.find(params[:id])
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
		params.require(:bin).permit(:mdpi_barcode, :identifier, :description, :batch, :current_workflow_status, condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :_destroy])

	end

	def assign_batch(params, bin)
		if params[:batch] and params[:batch][:id].length > 0
			puts("\n\n\nFinding a batch...")
			bin.batch = Batch.find(params[:batch][:id])	
		end
	end
end