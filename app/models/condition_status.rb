class ConditionStatus < ActiveRecord::Base

  belongs_to :condition_status_template
  belongs_to :physical_object

end
