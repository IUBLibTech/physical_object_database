class GroupKey < ActiveRecord::Base
  has_many :physical_objects
  after_initialize :set_defaults
  before_destroy :ungroup_objects

  validates :group_total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # default per_page value can be overriden in a request
  self.per_page = 50

  def group_identifier
    "GR" + id.to_s.rjust(8, "0")
  end

  def spreadsheet_descriptor
    group_identifier
  end

  def physical_objects_count
    physical_objects.size
  end

  private
  def set_defaults
    self.group_total ||= 1
  end

  #necessary to call because the default update to child objects does skips the before_validation check that runs ensure_group_key on a physical object to restore the group key
  def ungroup_objects
    self.physical_objects.each do |object|
      object.group_key = nil
      object.save
    end
  end

end
