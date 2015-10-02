class WorkflowStatusTemplatesController < ApplicationController
  before_action :set_wst, only: [:show, :edit, :update, :destroy]
  before_action :authorize_collection, only: [:index, :new, :create]

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
			redirect_to status_templates_path
		else
			render('new')
		end
	end

	def edit
	end

	def update
                old_i = @workflow_status_template.sequence_index.to_i
                new_i = params[:workflow_status_template][:sequence_index].to_i
		#if the sequence index has change we need to adjust any related templates
		move_sequence(@workflow_status_template, old_i, new_i) if old_i != new_i
		if @workflow_status_template.update_attributes(workflow_status_template_params)
			flash[:notice] = "#{@workflow_status_template.name} was successfully updated." + (old_i == new_i ? "" : "  Other templates may have updated sequence index values to avoid collisions.")
			redirect_to status_templates_path
		else
			flash[:warning] = "Unable to update #{@workflow_status_template.name}." + (old_i == new_i ? "" : "  Other templates may still have updated sequence index values to avoid collisions.")
			render('edit')
		end
	end
	
	def show
	end
	
	def destroy
		#decrement each following template
		temps = WorkflowStatusTemplate.where("sequence_index > ? AND object_type = ?", 
			@workflow_status_template.sequence_index, @workflow_status_template.object_type)
		temps.each do |t|
			t.sequence_index -= 1
			t.save
		end
		if @workflow_status_template.destroy
			flash[:notice] = "#{@workflow_status_template.name} successfully destroyed."

			redirect_to status_templates_path
		else 
			flash[:warning] = "Unable to delete #{@workflow_status_template.name}."
			render :show
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

		def move_sequence(existing_template, old_i, new_i)
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
		end

    def workflow_status_template_params
      params.require(:workflow_status_template).permit(:name, :description, :sequence_index, :object_type)
    end

    def set_wst
      @workflow_status_template = WorkflowStatusTemplate.find(params[:id])
      authorize @workflow_status_template
    end

    def authorize_collection
      authorize WorkflowStatusTemplate
    end

end
