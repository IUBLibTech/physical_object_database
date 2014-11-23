# FIXME: does anyone use these methods?
# extend in a model that can have workflow statuses 

module WorkflowStatusQueryModule

	# this finds all objects that have made it to or past a certain workflow status based on their CURRENT workflow
	def where_current_status_at_least(status)
		minimum_template = find_template(status)
		if minimum_template.nil?
		  self.none
		else
		  status_names = WorkflowStatusTemplate.where(object_type: self.name.underscore.humanize.titleize).where("sequence_index >= ?", minimum_template.sequence_index).map { |template| template.name }
		  self.where(workflow_status: status_names)
		end
	end 

	# returns the template of the workflow status that appears sequentially before the specified status name
	def status_name_before(status)
		statuses = WorkflowStatusTemplate.where(object_type: self.name.underscore.humanize.titleize).order(sequence_index: :desc)
		statuses.each_with_index do |stat, index|
			if (stat.name == status and statuses.size > index + 1) 
				return statuses[index+1]
			end
		end
		return nil
	end

	def find_template(status)
		WorkflowStatusTemplate.find_by(name: status, object_type: self.name.underscore.humanize.titleize)
	end
end
