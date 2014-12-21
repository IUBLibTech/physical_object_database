class WorkflowStatus < ActiveRecord::Base
	default_scope { order(:id) }

        belongs_to :workflow_status_template
        belongs_to :physical_object
        belongs_to :batch
        belongs_to :bin

        scope :sequenced, -> { joins(:workflow_status_template).order('workflow_status_templates.sequence_index ASC') }

        validates :workflow_status_template_id, presence: true
        validates :user, presence: true

	after_initialize :default_values

        def name
          return "" if self.workflow_status_template.nil?
          return self.workflow_status_template.name
        end

        def description
          return "" if self.workflow_status_template.nil?
          return self.workflow_status_template.description
        end

        def sequence_index
          return 0 if self.workflow_status_template.nil?
          return self.workflow_status_template.sequence_index
        end

	def default_values
	  self.user ||= SessionInfoModule.current_username
	end

end
