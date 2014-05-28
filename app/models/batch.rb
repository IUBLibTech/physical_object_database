class Batch < ActiveRecord::Base
	has_many :bins
	has_many :workflow_statuses, :dependent => :destroy
	
	include WorkflowStatusModule

	validates :identifier, presence: true, uniqueness: true
end
