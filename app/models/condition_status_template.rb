class ConditionStatusTemplate < ActiveRecord::Base

	has_many :condition_statuses
	validates :name, presence: true, uniqueness: true
	
        attr_accessor :object_types
        def object_types
                {"Physical Object" => "Physical Object"}
        end

        def self.select_options(object_type)
          options = {}
          self.where(object_type: object_type).order('sequence_index ASC').each do |template|
                options[template.name] = template.name
          end
          return options
        end

end
