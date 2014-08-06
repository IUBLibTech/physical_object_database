class Batch < ActiveRecord::Base
	has_many :bins
	has_many :workflow_statuses, :dependent => :destroy

	include WorkflowStatusModule
	after_initialize :assign_default_workflow_status


	validates :identifier, presence: true, uniqueness: true

	def physical_objects_count
	  return bins.inject(0) { |sum, bin| sum + bin.physical_objects_count }
	end


end
