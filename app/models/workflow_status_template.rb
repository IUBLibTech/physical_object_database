class WorkflowStatusTemplate < ActiveRecord::Base
	
	has_many :workflow_statuses, dependent: :destroy
	validates :name, presence: true, uniqueness: {scope: :object_type}
	validates :sequence_index, presence: true

	attr_accessor :object_types
	def object_types
		{"Physical Object" => "Physical Object",
		 "Batch" => "Batch",
		 "Bin" => "Bin"}
	end
	#FIXME: why is a name/name hash, while Condtion statuses have name/id?
	def self.select_options(object_type)
	  options = {}
	  self.where(object_type: object_type).order('sequence_index ASC').each do |template|
	  	options[template.name] = template.name
	  end
	  return options
	end

end
