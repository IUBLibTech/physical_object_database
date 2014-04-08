class WorkflowStatusTemplate < ActiveRecord::Base
	
	has_many :workflow_statuses
	validates :name, presence: true, uniqueness: true

	attr_accessor :object_types
	def object_types
		{"Physical Object" => "Physical Object",
		 "Batch" => "Batch",
		 "Bin" => "Bin"}
	end


end
