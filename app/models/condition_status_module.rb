# for use in objects that track condition status history
# current list: physical objects
# Requirements:
# Object including should have has_many :condition_statuses in model
# Object controller should permit :condition_statuses param array as a param
# ConditionStatusTemplate model should have belongs_to :object reference
# condition_status_templates table should have object_id field
module ConditionStatusModule

  def condition_status_options
    return ConditionStatusTemplate.select_options(self.class_title)
  end

  def class_title
    self.class.to_s.gsub(/([a-z])([A-Z])/, '\1 \2')
  end

  def ConditionStatusModule.has_condition?(object, status_name)
  	# TODO: optimize this with either a query or better ruby code
  	cst_list = ConditionStatusTemplate.where(name: status_name, object_type: object.class.name.titleize)
	found_flag = false
	# TODO: rewrite to distinguish case of status_name not valid?
	if cst_list.any?
		cst_id = cst_list.first.id
  		object.condition_statuses.each do |s|
  			found_flag = true if s.condition_status_template_id == cst_id
  		end
	end
  	found_flag
  end
end
