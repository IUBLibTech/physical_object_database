class GroupKey < ActiveRecord::Base
  has_many :physical_objects, dependent: :destroy
  after_initialize :set_defaults

  validates :group_total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def group_identifier
    "GR" + id.to_s.rjust(8, "0")
  end

  def spreadsheet_descriptor
    group_identifier
  end

  #delete if no associated objects?

  private
  def set_defaults
    self.group_total ||= 1
  end

end
