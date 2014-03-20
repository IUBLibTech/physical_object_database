class WorkflowStatus < ActiveRecord::Base

	belongs_to :workflow_status_template
	belongs_to :physical_object


end
