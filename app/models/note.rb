class Note < ActiveRecord::Base
  belongs_to :physical_object

  validates :user, presence: true
  validates :physical_object, presence: true
end
