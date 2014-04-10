class BinController < ApplicationController

	def index
		@bins = Bin.all
	end

	def new
		@bin = Bin.new
		@batches = Batch.find(:all, order: 'identifier').collect{|b| [b.identifier, b.id]}
	end

	def create
		@bin = Bin.new(bin_params)
		assign_batch(params, @bin)
		if @bin.identifier.nil? or @bin.identifier.length == 0
			flash[:notice] = "Cannot create a Bin without a (unique) identifier."
		elsif Bin.find_by(:identifier => @bin.identifier).nil?
			if @bin.save
				flash[:notice] = "<b>#{@bin.identifier}</b> was successfully created.".html_safe
				redirect_to(:action => 'index')
				return
			else
				flash[:warning] = "Warning! Unable to create <b>#{@bin.identifier}</b>".html_safe
			end
		else 
			flash[:notice] = 
			"Bin <b>#{@bin.identifier}</b> already exists. Identifiers must be unique.".html_safe
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
		assign_batch(params, @bin)
		if @bin.update_attributes(bin_params)
			flash[:notice] = "Successfully updated #{@bin.identifier}."
			redirect_to(:action => 'show', :id => @bin.id)
		else
			flash[:warning] = "Warning! Unable to create #{@bin.identifier}."
			render('show')
		end
	end

	def show
		@bin = Bin.find(params[:id])
	end

	def delete
		@bin = Bin.find(params[:id])
	end

	def destroy
		@bin = Bin.find(params[:id]).destroy
		flash[:notice] = "#{@bin.identifier} was successfully destroyed."
		redirect_to(:action => 'index')
	end

	def create_box
		redirect_to(action: 'show', id: params[:id])
	end

	def edit_box
		redirect_to(action: 'show', id: params[:id])
	end

	def remove_box
		redirect_to(action: 'show', id: params[:id])
	end

	def show_box
		redirect_to(action: 'show', id: params[:id])
	end

	private
	def bin_params
		params.require(:bin).permit(:barcode, :identifier, :description, :batch, :status, :current_workflow_status)
	end

	private
	def assign_batch(params, bin)
		if params[:batch] and params[:batch][:id].length > 0
			puts("\n\n\nFinding a batch...")
			bin.batch = Batch.find(params[:batch][:id])	
		end
	end
end
