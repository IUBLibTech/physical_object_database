class BinsController < ApplicationController

	def index
		@bins = Bin.all
		@unassigned = Box.where(bin_id: nil)
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
		@bin = Bin.find(params[:id])
		@batches = Batch.find(:all, order: 'identifier').collect{|b| [b.identifier, b.id]}
		@batch = @bin.batch
	end

	def update
		@bin = Bin.find(params[:id])
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
		@bin = Bin.find(params[:id])
		@physical_objects = @bin.physical_objects
		@edit_mode = false
	end

	def destroy
		@bin = Bin.find(params[:id])
		if @bin.destroy
			flash[:notice] = "<i>#{@bin.identifier}</i> was successfully destroyed.".html_safe
			redirect_to bins_path
		else
			flash[:notice] = "<b>Failed to delete this Bin</b>".html_safe
			render('show')
		end
	end

	def new_box
		@bin = Bin.find(params[:id])
		render(partial: 'new_box', box: Box.new(mdpi_barcode: 0))
	end

	def create_box
		bin = Bin.find(params[:id])
		box = Box.new
		box.mdpi_barcode = params[:box][:mdpi_barcode]
		box.bin = bin
		
		# one additional rule about boxes that does not apply to other record types: a box cannot be 
		# created without a valid mdpi_barcode. 0 is not allowed for this value
		if box.mdpi_barcode == 0
			box.errors.add(:mdpi_barcode, "must be assigned. Cannot be blank or 0.")
			render('create')
		elsif box.save
			flash[:notice] = "Successfully created box with MDPI Barcode: #{box.mdpi_barcode}."
			redirect_to(action: 'show', id: box.id)	
		else
			render('new_box')
		end
	end

	def show_box
		@edit_mode = false
		@box = Box.find(params[:id])
		@physical_objects = @box.physical_objects
		puts(@box.to_yaml)
		@bin = @box.bin
		puts("Found bin: #{@bin.to_s}")
	end

	def edit_box
		@edit_mode = true
		@action = 'update_box'
		@bins = Bin.all.order('identifier')
		@box = Box.find(params[:id])
		@physical_objects = @box.physical_objects
		# this is a little hackish but need to set the selected index in the drop down to reflect
		# the currently assigned bin (if it has been set)
		# also need to add one to the index because the form has a "Not Assigned" value at the top and 
		# selected_index is the position not value
		@selected_index = @box.bin.nil? ? 0 : bin_index(@bins, @box.bin_id) + 1
		puts("Selected index = #{@selected_index}")
	end

	def update_box
		bin_id = params[:box][:bin_id]
		puts("Adding to bin: #{bin_id}")
		bin = (!bin_id.nil? and bin_id.length > 0) ? Bin.find(bin_id) : nil
		box = Box.find(params[:id])
		box.bin = bin
		if box.save
			flash[:notice] = "Successfully added Box <i>#{box.mdpi_barcode}</i> to Bin <i>#{bin.identifier}</i>".html_safe
		else
			flash[:notice] = "<b class='warning'>Unable to update Box <i>#{box.mdpi_barcode}</i></b>".html_safe
		end
		redirect_to(action: 'show_box', id: box.id)
	end

	def remove_box
		box = Box.find(params[:id])
		box.bin = nil
		box.save
		redirect_to(action: 'show', id: params[:bin_id])
	end

	def bin_add_item
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

	def remove_physical_object
		c = nil
		id = nil
		po = PhysicalObject.find(params[:id])
		if !po.box.nil?
			c = 'box'
			id = po.box.id
			po.box = nil
			flash[:notice] = "<i>#{po.title}</i> successully remove from the Box".html_safe
		elsif !po.bin.nil?
			c = 'bin'
			id = po.bin.id
			po.bin = nil
			flash[:notice] = "<i>#{po.title}</i> successully removed from the Bin".html_safe
		else
			flash[:notice] ="<b class='red'>Warning! #{po.title} was not associated with a Bin or a Box... no changes made to the POD</b>"
		end
		po.save
		redirect_to(action: (c == 'bin' ? 'show' : 'show_box'), id: id)
	end

	private
	def bin_index(bins, bin_id)
		bins.each_with_index { |bin, i|
			puts(bin)
			if bin[1] == bin_id
				return i
			end
		}
		0
	end

	private
	def bin_params
		params.require(:bin).permit(:mdpi_barcode, :identifier, :description, :batch, :current_workflow_status, condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :_destroy])

	end

	private
	def assign_batch(params, bin)
		if params[:batch] and params[:batch][:id].length > 0
			puts("\n\n\nFinding a batch...")
			bin.batch = Batch.find(params[:batch][:id])	
		end
	end
end
