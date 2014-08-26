class ConditionStatusTemplate < ActiveRecord::Base

	has_many :condition_statuses
	validates :name, presence: true, uniqueness: true, uniqueness: {scope: :object_type}
	#validates :object_type, presence: true
	
        attr_accessor :object_types
        def object_types
                {"Physical Object" => "Physical Object",
		 "Bin" => "Bin"}
        end
	#FIXME: why is this a name/id hash, while Workflow statuses have name/name?
        def self.select_options(object_type)
          options = {}
          self.where(object_type: object_type).order('name ASC').each do |template|
                options[template.name] = template.id
          end
          return options
        end

end
