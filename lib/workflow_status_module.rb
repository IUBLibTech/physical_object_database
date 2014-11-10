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
    self.current_workflow_status ||= default_workflow_status if self.new_record?
  end

  def assign_inferred_workflow_status
    self.current_workflow_status = self.inferred_workflow_status
  end

  #return highest-ranking workflow status
  def current_workflow_status
    return self.workflow_status
  end

  # requires object save afterwards to take effect
  # return blank string for no assignment, status text for assignment, raise error for invalid assignment
  def current_workflow_status=(workflow_status_name)
    return if workflow_status_name == self.current_workflow_status
    workflow_status_template = WorkflowStatusTemplate.find_by(name: workflow_status_name, object_type: self.class_title)
    if workflow_status_template.nil?
      raise RuntimeError, "Status value of \"#{workflow_status_name}\" cannot be assigned to a #{self.class_title}"
      return nil
    end
    self.workflow_status = workflow_status_name
    self.workflow_statuses.new(workflow_status_template_id: workflow_status_template.id)
  end

  def default_workflow_status
    self.is_a?(PhysicalObject) ? "Unassigned" : "Created"
  end

  # override in an implementation
  def inferred_workflow_status
    return ""
  end

  def workflow_status_options
    return WorkflowStatusTemplate.select_options(self.class_title)
  end

  def class_title
    self.class.name.underscore.humanize.titleize
  end

end
