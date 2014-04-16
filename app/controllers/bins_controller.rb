class BinsController < ApplicationController

	def index
		@bins = Bin.all
		@unassigned = Box.where(bin_id: nil)
	end

	def new
		@bin = Bin.new
		@batches = Batch.find(:all, order: 'identifier').collect{|b| [b.identifier, b.id]}
	end

	def create
		@bin = Bin.new(bin_params)
		assign_batch(params, @bin)
		if @bin.identifier.nil? or @bin.identifier.length == 0
			flash[:notice] = "<b class='warning'>Cannot create a Bin without a (unique) identifier.</b>".html_safe
		elsif Bin.find_by(:identifier => @bin.identifier).nil?
			if @bin.save
				flash[:notice] = "<b>#{@bin.identifier}</b> was successfully created.".html_safe
				redirect_to(:action => 'index')
				return
			else
				flash[:notice] = "<b class='warning'>Warning! Unable to create <i>#{@bin.identifier}</i></b>".html_safe
			end
		else 
			flash[:notice] = 
			"<b class='warning'>Bin <i>#{@bin.identifier}</i> already exists. Identifiers must be unique.</b>".html_safe
		end
		redirect_to(:action => 'new')
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
			flash[:warning] = "<b class='warning'>Warning! Unable to create <i>#{@bin.identifier}</i>.</b>".html_safe
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
		@bin.destroy
		flash[:notice] = "<i>#{@bin.identifier}</i> was successfully destroyed.".html_safe
		redirect_to bins_path
	end

	def new_box
		@bin = Bin.find(params[:id])
		render(partial: 'new_box', box: Box.new)
	end

	def create_box
		if Box.exists?(mdpi_barcode: params[:box][:mdpi_barcode])
			flash[:notice] = "<b class='warning'>A box with MDPI barcode <i>#{params[:box][:mdpi_barcode]}</i> already exists.</b>".html_safe
		else
			if params[:box][:mdpi_barcode].length > 0
				bin = Bin.find(params[:id])
				box = Box.new
				box.mdpi_barcode = params[:box][:mdpi_barcode]
				box.bin = bin
				box.save
			else
				flash[:notice] = "<b class='warning'>You must specify a barcode to create a new box</b>".html_safe
			end
		end
		redirect_to(action: 'show', id: params[:id])
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
		# this is a little hackish but need to set the selected index in the drop down to reflect
		# the currently assigned bin (if it has been set)
		# also need to add one to the index because the form has a "Not Assigned" value at the top and 
		# selected_index is the position not value
		@selected_index = @box.bin.nil? ? 0 : bin_index(@bins, @box.bin_id) + 1
		puts("Selected index = #{@selected_index}")
	end

	def update_box
		bin_id = params[:box][:bin]
		puts("Adding to bin: #{bin_id}")
		bin = (!bin_id.nil? and bin_id.length > 0) ? Bin.find(bin_id) : nil
		box = Box.find(params[:id])
		box.bin = bin
		if box.save
			flash[:notice] = "Successfully updated Box <i>#{box.mdpi_barcode}</i>".html_safe
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
		bin = Bin.find(params[:bin][:id])
		if Box.exists?(mdpi_barcode: bc)
			box = Box.where(mdpi_barcode: bc).first
			box.bin = bin
			box.save
			flash[:notice] = "Successfully added Box <i>#{box.mdpi_barcode}</i> to the Bin.".html_safe
		elsif PhysicalObject.exists?(mdpi_barcode: bc)
			po = PhysicalObject.where(mdpi_barcode: bc).first
			po.bin = bin
			po.save
			flash[:notice] = "Successfully added Physical Objecj <i>#{po.mdpi_barcode}</i> to Bin #{bin.identifier}.".html_safe
		else
			box = Box.new
			box.mdpi_barcode = bc
			box.bin = bin
			box.save
			flash[:notice] = "Successfully created new Box <i>#{bc}</i> and added it to Bin <i>#{bin.identifier}</i>".html_safe
		end
		redirect_to(action: 'show', id: bin.id)
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
		#this case shouldn't happen unless someone tries to assemble a URL manually instead of following a link
		else
			flash[:notice] ="<b class='red'>Warning! #{po.title} was not associated with a Bin or a Box... no changes made to the POD</b>"
		end
		po.save
		redirect_to(action: (c == 'bin' ? 'show' : 'show_box'), id: id)
	end

	def box_add_item
		@box = Box.find(params[:box][:id])
		bc = params[:barcode][:mdpi_barcode]
		if PhysicalObject.exists?(mdpi_barcode: bc)
			po = PhysicalObject.where(mdpi_barcode: bc).first
			#TODO: what if a barcoded item has already been assigned to something else?
			if po.box.nil? and po.bin.nil?
				po.box = @box
				po.save
				flash[:notice] = "Physical Object <i>#{po.title}</i> was successully added to Box <i>#{@box.mdpi_barcode}</i>".html_safe
			else
				if !po.box.nil?
					flash[:notice] = "<b class='warning'>#{po.title} already belongs to <a href=''>Box[#{po.box.identifier}]</a></b>".html_safe
				else
					flash[:notice] = "<b class='warning'>#{po.title} already belongs to <a href=''>Bin[#{po.box.identifier}]</a></b>".html_safe
				end
			end
		else
			flash[:notice] = "<b class='warning'>There is no Physical Object with MDPI barcode: #{bc}</a></b>".html_safe
		end
		redirect_to(action: 'show_box', id: @box.id )
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
		params.require(:bin).permit(:barcode, :identifier, :description, :batch, :current_workflow_status, condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :_destroy])

	end

	private
	def assign_batch(params, bin)
		if params[:batch] and params[:batch][:id].length > 0
			puts("\n\n\nFinding a batch...")
			bin.batch = Batch.find(params[:batch][:id])	
		end
	end
end
