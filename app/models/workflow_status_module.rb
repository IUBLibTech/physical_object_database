# for use in objects that track workflow status history
# current list: physical objects, bins, batches
# Requirements:
# Object including should call after_create :assign_default_workflow_status
# Object including should have has_many :workflow_statuses in model
# Object controller should permit :current_workflow_status as a param
# WorkflowStatusTemplate model should have belongs_to :object reference
# workflow_status_templates table should have object_id field
module WorkflowStatusModule

  def assign_default_workflow_status
    self.current_workflow_status = default_workflow_status
  end

  #return highest-ranking workflow status
  def current_workflow_status
    return nil if self.workflow_statuses.nil? || self.workflow_statuses.size.zero?
    return self.workflow_statuses.last
  end

  def current_workflow_status=(workflow_status_name)
    return if workflow_status_name.nil? || workflow_status_name.blank?
    workflow_status_template = WorkflowStatusTemplate.find_by(name: workflow_status_name, object_type: self.class_title)
    return if workflow_status_template.nil?
    return if !self.current_workflow_status.nil? and workflow_status_template.id == self.current_workflow_status.workflow_status_template.id
    self.workflow_statuses.new(workflow_status_template_id: workflow_status_template.id)
  end

  def default_workflow_status
    self.is_a?(Bin) ? "Labelled" : "Created"
  end

  def workflow_status_options
    return WorkflowStatusTemplate.select_options(self.class_title)
  end

  def class_title
    self.class.to_s.gsub(/([a-z])([A-Z])/, '\1 \2')
  end

end
