class ConditionStatusTemplate < ActiveRecord::Base

	has_many :condition_statuses
	OBJECT_TYPES = { "Physical Object" => "Physical Object", "Bin" => "Bin" }
	validates :name, presence: true, uniqueness: {scope: :object_type}
	validates :object_type, presence: true, inclusion: { in: OBJECT_TYPES.keys }
        scope :blocking, lambda { where(blocks_packing: true) }
	
        attr_accessor :object_types

	def self.blocking_ids
          @blocking_ids ||= ConditionStatusTemplate.blocking.map { |cst| cst.id }
        end

        def object_types
                ConditionStatusTemplate::OBJECT_TYPES
        end

        def self.select_options(object_type)
          options = {}
          self.where(object_type: object_type).order('name ASC').each do |template|
                options[template.name] = template.id
          end
          return options
        end

end
