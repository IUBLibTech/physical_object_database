class WorkflowStatus < ActiveRecord::Base

	belongs_to :workflow_status_template
	belongs_to :physical_object
	belongs_to :batch
	belongs_to :bin

	scope :sequenced, -> { joins(:workflow_status_template).order('workflow_status_templates.sequence_index ASC') }

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

end
