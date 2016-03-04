# for use in objects that track condition status history
# current list: physical objects, bin (but no statuses defined)
# Requirements:
# Object including should have has_many :condition_statuses in model
# Object controller should permit :condition_statuses param array as a param
# ConditionStatusTemplate model should have belongs_to :object reference
# condition_status_templates table should have object_id field
#
# RSpec testing is via shared shared examples call in including models
module ConditionStatusModule

  def condition_status_options
    return ConditionStatusTemplate.select_options(self.class_title)
  end

  def class_title
    self.class.name.gsub(/([a-z])([A-Z])/, '\1 \2')
  end

  def has_condition?(status_name)
  	cst = ConditionStatusTemplate.find_by(name: status_name, object_type: self.class_title)
	if cst.nil?
		return false
	else
		self.condition_statuses.any? { |cs| cs.condition_status_template_id == cst.id and cs.active? }
	end
  end
end
