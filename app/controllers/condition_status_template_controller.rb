class ConditionStatusTemplateController < ApplicationController

  def index
    @all_condition_status_templates = {}
    ConditionStatusTemplate.new.object_types.keys.each do |object_type|
      @all_condition_status_templates[object_type] = ConditionStatusTemplate.where(object_type: object_type).order('name ASC')
    end
  end

  def condition
    @condition_status_template = ConditionStatusTemplate.new
    @condition_status_template.object_type = @condition_status_template.object_types["Physical Object"]
    render('new')
  end

  def new
    @condition_status_template = ConditionStatusTemplate.new
  end

  def create
    @condition_status_template = ConditionStatusTemplate.new(condition_status_template_params)
    if @condition_status_template.save
      redirect_to(controller: 'status_templates', action: 'index')
    else
      render('new')
    end
  end

  def edit
    @condition_status_template = ConditionStatusTemplate.find(params[:id])
  end

  def update
    @condition_status_template = ConditionStatusTemplate.find(params[:id])
    if @condition_status_template.update_attributes(condition_status_template_params)
      flash[:notice] = "#{@condition_status_template.name} was successfully updated."
      redirect_to(action: 'index', id: @condition_status_template.id)
    else
      flash[:warning] = "Unable to update #{@condition_status_template.name}."
      render('edit')
    end
  end
  
  def show
    @condition_status_template = ConditionStatusTemplate.find(params[:id])
  end
  
  def delete
    @condition_status_template = ConditionStatusTemplate.find(params[:id])
  end

  def destroy
    @condition_status_template = ConditionStatusTemplate.find(params[:id])
    if @condition_status_template.destroy
      flash[:notice] = "#{@condition_status_template.name} successfully destroyed."
      redirect_to(action: 'index')
    else 
      flash[:warning] = "Unable to delete #{@condition_status_template.name}."
      render('delete')
    end
   end

  private
    def condition_status_template_params
      params.require(:condition_status_template).permit(:name, :description, :object_type)
    end

end
