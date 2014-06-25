class Batch < ActiveRecord::Base
	has_many :bins
	has_many :workflow_statuses, :dependent => :destroy

	after_create :assign_default_workflow_status
	include WorkflowStatusModule

	validates :identifier, presence: true, uniqueness: true

end
