# for use in objects that track workflow status history
# current list: physical objects, bins, batches
# Requirements:
# Object including should call after_create :assign_default_workflow_status
# Object including should have has_many :workflow_statuses in model
# Object controller should permit :current_workflow_status as a param
# WorkflowStatusTemplate model should have belongs_to :object reference
# workflow_status_templates table should have object_id field
#
# RSpec testing is via shared shared examples call in including models
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
    self.workflow_index = workflow_status_template.sequence_index
    self.workflow_statuses.new(workflow_status_template_id: workflow_status_template.id)
  end

  # creates a new log entry for the same workflow status; used for physical object ephemera update
  def duplicate_workflow_status
    return if self.workflow_statuses.none?
    self.workflow_statuses.create(workflow_status_template_id: self.workflow_statuses.last.workflow_status_template_id)
  end

  def default_workflow_status
    self.is_a?(PhysicalObject) ? "Unassigned" : "Created"
  end

  # override in an implementation
  def inferred_workflow_status
    return ""
  end

  def display_workflow_status
    return self.current_workflow_status
  end

  def workflow_status_options
    return WorkflowStatusTemplate.select_options(self.class_title)
  end

  def class_title
    self.class.name.underscore.humanize.titleize
  end

  def previous_workflow_status
    previous_hash = workflow_status_options.inject({ :previous => ""}) { |h, (k, v)| h[k] = h[:previous]; h[:previous] = v; h }
    previous_hash[self.current_workflow_status].to_s
  end

  def next_workflow_status
    next_hash = {}
    status_array = workflow_status_options.to_a
    status_array.to_a.each_with_index do |k_v, index|
      if index == status_array.size - 1
        next_hash[k_v.first] = ""
      else
        next_hash[k_v.first] = status_array[index+1].last
      end
    end
    next_hash[self.current_workflow_status].to_s
  end

end
