class Note < ActiveRecord::Base
  XML_EXCLUDE = [:physical_object_id]
  include XMLExportModule

  belongs_to :physical_object

  validates :user, presence: true
  validates :physical_object, presence: true, on: :update

  after_initialize :default_values

  def default_values
    self.export ||= false if self.new_record?
    self.user ||= User.current_user
  end

end
