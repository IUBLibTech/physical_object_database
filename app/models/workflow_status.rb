class WorkflowStatus < ActiveRecord::Base
  XML_INCLUDE = [:name, :sequence_index, :workflow_note]
  XML_EXCLUDE = [:workflow_status_template_id, :physical_object_id, :bin_id, :batch_id, :notes]
  include XMLExportModule

	default_scope { order(:id) }

        belongs_to :workflow_status_template
        belongs_to :physical_object
        belongs_to :batch
        belongs_to :bin

        scope :sequenced, -> { joins(:workflow_status_template).order('workflow_status_templates.sequence_index ASC') }

        validates :workflow_status_template_id, presence: true
        validates :user, presence: true

	after_initialize :default_values, if: :new_record?
	before_save :set_ephemera_values, if: :physical_object_id

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

  # name spoof for to_xml
  def workflow_note
    self.notes
  end

  def default_values
    self.user ||= User.current_user
  end

  # ephemera_okay is set true/false if applicable, nil otherwise
  def set_ephemera_values
    if self.physical_object
      self.has_ephemera = self.physical_object.has_ephemera?
      self.ephemera_returned = self.physical_object.ephemera_returned?
      if self.physical_object.has_ephemera? && self.physical_object.workflow_status.in?(PhysicalObject::EPHEMERA_RETURNED_STATUSES)
        self.ephemera_okay = self.physical_object.ephemera_returned?
      else
        self.ephemera_okay = nil
      end
      [self.has_ephemera, self.ephemera_returned, self.ephemera_okay]
    end
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
