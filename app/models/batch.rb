class Batch < ActiveRecord::Base
	has_many :bins
	has_many :workflow_statuses, :dependent => :destroy
	
	include WorkflowStatusModule

	validates :identifier, presence: true, uniqueness: true
	after_create :init

	def init
		default_status = WorkflowStatusQueryModule.default_status(self)
    self.workflow_statuses << default_status
	end
end
