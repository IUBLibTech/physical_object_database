class ConditionStatus < ActiveRecord::Base
  XML_INCLUDE = [:name, :blocks_packing, :condition_note]
  XML_EXCLUDE = [:condition_status_template_id, :physical_object_id, :bin_id, :notes]
  include XMLExportModule

  belongs_to :condition_status_template
  belongs_to :physical_object
  belongs_to :bin
  
  validates :condition_status_template_id, presence: true, uniqueness: { scope: [:physical_object_id, :bin_id] }
  validates :user, presence: true
  validates :physical_object, presence: true, on: :update

  after_initialize :default_values, if: :new_record?

  scope :blocking, lambda { where(active: true, condition_status_template_id: ConditionStatusTemplate.blocking_ids) }

  def name
    return "" if self.condition_status_template.nil?
    return self.condition_status_template.name
  end

  def description
    return "" if self.condition_status_template.nil?
    return self.condition_status_template.description
  end

  def default_values
    self.active ||= true
    self.user ||= User.current_user
  end

  def blocks_packing
    return nil if self.condition_status_template.nil?
    return self.condition_status_template.blocks_packing?
  end

  # name spoof for to_xml
  def condition_note
    self.notes
  end

end
