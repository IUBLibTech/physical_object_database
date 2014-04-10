class Batch < ActiveRecord::Base
	has_many :bins
	has_many :workflow_statuses
	include WorkflowStatusModule

end
