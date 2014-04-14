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
end
