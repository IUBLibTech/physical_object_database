class WorkflowStatus < ActiveRecord::Base
	default_scope { order(:id) }

        belongs_to :workflow_status_template
        belongs_to :physical_object
        belongs_to :batch
        belongs_to :bin

        scope :sequenced, -> { joins(:workflow_status_template).order('workflow_status_templates.sequence_index ASC') }

        validates :workflow_status_template_id, presence: true
        validates :user, presence: true

	after_initialize :default_values

  def name
    return "" if self.workflow_status_template.nil?
    return self.workflow_status_template.name
  end

  def description
    return "" if self.workflow_status_template.nil?
    return self.workflow_status_template.description
  end

  def sequence_index
    return 0 if self.workflow_status_template.nil?
    return self.workflow_status_template.sequence_index
  end

	def default_values
	  self.user ||= SessionInfoModule.current_username
	end

  def past_status?(status_name)
    past? status_name, :>
  end

  def past_or_equal_status?(status_name)
    past? status_name, :>=
  end

  private
  def past? status_name, operator
    named_template = WorkflowStatusTemplate.template_by_status_name(workflow_status_template.object_type, status_name)
    if named_template.nil?
      raise "Unknown template name for #{workflow_status_template.object_type}: #{status_name}"
    end
    return sequence_index.send(operator, named_template.sequence_index)
  end
  

end
