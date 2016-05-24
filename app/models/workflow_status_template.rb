class WorkflowStatusTemplate < ActiveRecord::Base
	
	has_many :workflow_statuses, dependent: :destroy
	validates :name, presence: true, uniqueness: {scope: :object_type}
	OBJECT_TYPES = {"Physical Object" => "Physical Object",
		 "Batch" => "Batch",
		 "Bin" => "Bin"}
	validates :object_type, presence: true, inclusion: { in: OBJECT_TYPES }
	validates :sequence_index, presence: true

	attr_accessor :object_types
	def object_types
		OBJECT_TYPES
	end

	def self.select_options(object_type)
	  options = {}
	  self.where(object_type: object_type).order('sequence_index ASC').each do |template|
	  	options[template.name] = template.name
	  end
	  return options
	end

        def self.select_id_options(object_type)
          options = {}
	  self.where(object_type: object_type).order('sequence_index ASC').each do |template|
                options[template.name] = template.id
          end
          return options
        end

	def self.template_by_status_name(object_type, name)
		WorkflowStatusTemplate.where(object_type: object_type, name: name).first
	end

end
