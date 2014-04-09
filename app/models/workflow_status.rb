class WorkflowStatus < ActiveRecord::Base

	belongs_to :workflow_status_template
	belongs_to :physical_object
	belongs_to :batch
	belongs_to :bin
	#FIXME: drop condition_status_template_id
	#FIXME: drop notes, order?
	#FIXME: add indexes?

	scope :sequenced, -> { joins(:workflow_status_template).order('workflow_status_templates.sequence_index ASC') }

end
