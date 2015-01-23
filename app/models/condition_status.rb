class ConditionStatus < ActiveRecord::Base

  belongs_to :condition_status_template
  belongs_to :physical_object
  belongs_to :bin
  
  validates :condition_status_template_id, presence: true, uniqueness: { scope: [:physical_object_id, :bin_id] }
  validates :user, presence: true

  after_initialize :default_values

  def name
    return "" if self.condition_status_template.nil?
    return self.condition_status_template.name
  end

  def description
    return "" if self.condition_status_template.nil?
    return self.condition_status_template.description
  end

  def default_values
    self.active ||= true if self.new_record?
    self.user ||= User.current_user if self.new_record?
  end

end
