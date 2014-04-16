class PicklistsController < ApplicationController

	def new
		@picklist = Picklist.new
		@edit_mode = true
		@submit_text = "Create Picklist"
		@action = 'create'
	end

	def create
		@picklist = Picklist.new(picklist_params)
		if Picklist.exists?(name: @picklist.name)
			flash[:notice] = "A picklist with name: #{@picklist.name} already exists."
			render('new')
		elsif @picklist.save
			flash[:notice] = "Successfully created #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: "index")
		else
			flash[:notice] = "Unable to create #{@picklist.name}"
			render('new')
		end
	end

	def show
		if request.format.csv? || request.format.xls?
			params[:id] = params[:id].sub(/picklist_/, '')
		end
		@picklist = Picklist.find(params[:id])
		@physical_objects = PhysicalObject.where(picklist_id: @picklist.id)
		@edit_mode = false

		respond_to do |format|
			format.html
			format.csv { send_data PhysicalObject.to_csv(@physical_objects) }
			format.xls
		end
	end

	def edit
		@picklist = Picklist.find(params[:id])
		@edit_mode = true
		@action = 'update'
		@submit_text = "Update Picklist"
	end

	def update
		@picklist = Picklist.find(params[:id])
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
			flash[:notice] = "Failed to update #{@picklist.name}"
			render('edit')
		end
	end

	def destroy
		@picklist = Picklist.find(params[:id])
		if @picklist.destroy
			flash[:notice] = "Successfully deleted #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')
		else
			flash[:notice] = "Unable to delete #{@picklist.name}"
			redirect_to(controller: 'picklist_specifications', action: 'index')
		end		
	end

	def remove
		@picklist = Picklist.find(params[:id])
		po = PhysicalObject.find(params[:po_id])
		if po.picklist_id == @picklist.id
			if po.update_attributes(picklist_id: nil)
				flash[:notice] = "#{po.title} was successfully removed from the pocklist"
			else
				flash[:notice] = "Unable to remove #{po.title} from the pocklist"
			end
		end
		redirect_to(action: 'show', id: picklist.id) 
	end

  def csv
    @picklist = Picklist.find(params[:id])
    @physical_objects = PhysicalObject.where(picklist_id: @picklist.id)
    send_data PhysicalObject.to_csv(@physical_objects)
  end


	private
		def picklist_params
			params.require(:picklist).permit(:name, :description)
		end

end
