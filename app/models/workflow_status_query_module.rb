module WorkflowStatusQueryModule

	def WorkflowStatusQueryModule.where_current_status_is(object_class, status)
		sql = current_status_query(object_class, status)
		object_class.find_by_sql(sql)
	end

	def WorkflowStatusQueryModule.in_bin_where_current_status_is(bin, status)
		sql = current_status_query(PhysicalObject, status)
		new_sql = "SELECT physical_objects.* FROM physical_objects " << 
		"INNER JOIN (#{sql}) stat ON physical_objects.id = stat.id " <<
		"WHERE physical_objects.bin_id = #{bin.id}"
		PhysicalObject.find_by_sql(new_sql)
	end

	# this finds all objects that have made it to or past a certain workflow status based on their CURRENT workflow
	def WorkflowStatusQueryModule.where_current_status_at_least(object_class, status)
		wst_id = template_id(object_class, status)
		t = table(object_class)
		inner_sql = "SELECT outside.#{t.singularize}_id " << 
		"FROM workflow_status_templates INNER JOIN (" <<
    	"SELECT workflow_statuses.* " <<
    	"FROM workflow_statuses INNER JOIN ( " <<
        "SELECT #{t.singularize}_id, MAX(created_at) time " <<
        "FROM workflow_statuses " <<
        "GROUP BY #{t.singularize}_id) inside " <<
    	"ON workflow_statuses.#{t.singularize}_id = inside.#{t.singularize}_id " <<
    	"AND workflow_statuses.created_at = inside.time " <<
    	"WHERE workflow_statuses.#{t.singularize}_id IS NOT NULL " <<
    ") outside " <<
		"ON outside.workflow_status_template_id = workflow_status_templates.id " <<
		"WHERE workflow_status_templates.id >= #{wst_id}"

		sql = "SELECT #{t}.* FROM #{t} INNER JOIN (#{inner_sql}) inner_sql " <<
		"ON #{t}.id = inner_sql.#{t.singularize}_id"
		object_class.find_by_sql(sql)

	end 

	def WorkflowStatusQueryModule.default_status(object)
		wst_id = object.is_a?(Bin) ? template_id(Bin, "Labelled") : template_id(object.class, "Created")
		WorkflowStatus.new(workflow_status_template_id: wst_id)
	end

	def WorkflowStatusQueryModule.new_status(object, status_name)
		wst_id = template_id(object.class, status_name)
		ws = WorkflowStatus.new(workflow_status_template_id: wst_id)
		if object.is_a?(PhysicalObject)
			ws.physical_object_id = object.id
		elsif object.is_a?(Bin)
			ws.bin_id = object.id
		elsif object.is_a?(Batch)
			ws.batch_id = object.id
		end
		ws		
	end
	# returns the name of the workflow status that appears sequenctially before the specified status name
	def WorkflowStatusQueryModule.status_name_before(object_class, status)
		statuses = WorkflowStatusTemplate.where(object_type: object_class.name.underscore.humanize.titleize).order(sequence_index: :desc)
		statuses.each_with_index do |stat, index|
			if (stat.name == status and statuses.size > index + 1) 
				return statuses[index+1]
			end
		end
		return nil
	end

	private
	def WorkflowStatusQueryModule.template_id(object_class, status)
		WorkflowStatusTemplate.where(name: status, object_type: object_class.name.underscore.humanize.titleize)[0].id
	end

	def WorkflowStatusQueryModule.current_status_query(object_class, status)
		wst_id = template_id(object_class, status)
		t = table(object_class)
		# this query grabs all current workflow statuses. MySQL blows up if you try to specify anything other than that
		# MAX(created_at) and GROUP BY field which is why the INNER JOIN with the next query is necessary
		innermost_sql = 
			"SELECT #{t.singularize}_id, MAX(created_at) as first_time " <<
			"FROM workflow_statuses GROUP BY #{t.singularize}_id"

		# This query joins the batch/bin/physical_object_id back to it's current workflow status so that you can
		# now filter out based on a specific status
		inner_sql = 
			"SELECT workflow_statuses.* FROM workflow_statuses INNER JOIN (#{innermost_sql}) innermost " <<
			"ON workflow_statuses.#{t.singularize}_id = innermost.#{t.singularize}_id " <<
			"AND workflow_statuses.created_at = innermost.first_time " <<
			"WHERE workflow_status_template_id = #{wst_id}"
		
		# This final query returns all object_class records that have that status
		sql = "SELECT #{t}.* FROM #{t} " <<
		"INNER JOIN (#{inner_sql}) outer_inner ON #{t}.id = outer_inner.#{t.singularize}_id"
	end

	def WorkflowStatusQueryModule.table(object_class)
		if object_class == Batch
			"batches"
		elsif object_class == Bin
			"bins"
		elsif object_class == PhysicalObject
			"physical_objects"
		else
			nil
		end
	end

end