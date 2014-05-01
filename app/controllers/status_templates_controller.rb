class StatusTemplatesController < ApplicationController

  def index
    @all_workflow_status_templates = {}
    WorkflowStatusTemplate.new.object_types.keys.each do |object_type|
      @all_workflow_status_templates[object_type] = WorkflowStatusTemplate.where(object_type: object_type).order('sequence_index ASC')
    end
    @all_condition_status_templates = {}
    ConditionStatusTemplate.new.object_types.keys.each do |object_type|
      @all_condition_status_templates[object_type] = ConditionStatusTemplate.where(object_type: object_type).order('name ASC')
    end
  end

end
