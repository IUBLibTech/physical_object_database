class WorkflowStatusTemplateController < ApplicationController

	def workflow
		@workflow_status_template = WorkflowStatusTemplate.new
		@workflow_status_template.object_type = @workflow_status_template.object_types["Physical Object"]
		render('new')
	end

	def new
		@workflow_status_template = WorkflowStatusTemplate.new
	end

	def create
		@workflow_status_template = WorkflowStatusTemplate.new(workflow_status_template_params)
		if insert_sequence(@workflow_status_template)
			redirect_to(controller: 'status_templates', action: 'index')
		else
			render('new')
		end
	end

	def edit
		@workflow_status_template = WorkflowStatusTemplate.find(params[:id])
	end

	def update
		@workflow_status_template = WorkflowStatusTemplate.find(params[:id])
		#if the sequence index has change we need to adjust any related templates
		if @workflow_status_template.sequence_index != params[:workflow_status_template][:sequence_index]
			move_sequence(@workflow_status_template)
			redirect_to(action: 'show', id: @workflow_status_template.id)
		else
			if @workflow_status_template.update_attributes(workflow_status_template_params)
				flash[:notice] = "#{@workflow_status_template.name} was successfully updated."
				redirect_to(action: 'index', id: @workflow_status_template.id)
			else
				flash[:warning] = "Unable to update #{@workflow_status_template.name}."
				render('edit')
			end
		end
	end
	
	def show
		@workflow_status_template = WorkflowStatusTemplate.find(params[:id])
	end
	
	def delete
		@workflow_status_template = WorkflowStatusTemplate.find(params[:id])
	end

	def destroy
		@workflow_status_template = WorkflowStatusTemplate.find(params[:id])
		#decrement each following template
		temps = WorkflowStatusTemplate.where("sequence_index > ? AND object_type = ?", 
			@workflow_status_template.sequence_index, @workflow_status_template.object_type)
		temps.each do |t|
			t.sequence_index -= 1
			t.save
		end
		if @workflow_status_template.destroy
			flash[:notice] = "#{@workflow_status_template.name} successfully destroyed."
			redirect_to(action: 'index')
		else 
			flash[:warning] = "Unable to delete #{@workflow_status_template.name}."
			render('delete')
		end
 	end

	private
		def insert_sequence(workflow_status_template)
			if WorkflowStatusTemplate.exists?(sequence_index: workflow_status_template.sequence_index)
				temps = WorkflowStatusTemplate.where("sequence_index >= ? AND object_type = ?", 
					workflow_status_template.sequence_index, workflow_status_template.object_type)
				temps.each do |t|
					t.sequence_index += 1
					t.save
				end
			end
			workflow_status_template.save
		end

	private
		def move_sequence(existing_template)
			old_i = existing_template.sequence_index.to_i
			new_i = params[:workflow_status_template][:sequence_index].to_i
			if new_i < old_i
				temps = WorkflowStatusTemplate.where("sequence_index >= ? AND sequence_index < ? AND object_type = ?", 
					new_i, old_i, existing_template.object_type)
				temps.each do |t|
					t.sequence_index += 1
					t.save
				end
			elsif new_i > old_i
				temps = WorkflowStatusTemplate.where("sequence_index > ? AND sequence_index <= ? AND object_type = ?",
					old_i, new_i, existing_template.object_type)
				temps.each do |t|  
					t.sequence_index -= 1
					t.save
				end
			end
			existing_template.update_attributes(workflow_status_template_params)
		end

	private
    def workflow_status_template_params
      params.require(:workflow_status_template).permit(:name, :description, :sequence_index, :object_type)
    end

end
