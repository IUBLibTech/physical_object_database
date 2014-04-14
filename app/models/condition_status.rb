class ConditionStatus < ActiveRecord::Base

  belongs_to :condition_status_template
  belongs_to :physical_object
  
  validates :condition_status_template_id, presence: true

  def name
    return "" if self.condition_status_template.nil?
    return self.condition_status_template.name
  end

  def description
    return "" if self.condition_status_template.nil?
    return self.condition_status_template.description
  end

end
