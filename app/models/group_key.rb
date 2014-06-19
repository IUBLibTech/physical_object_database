class GroupKey < ActiveRecord::Base
  has_many :physical_objects

  validates :identifier, presence: true, uniqueness: true
end
