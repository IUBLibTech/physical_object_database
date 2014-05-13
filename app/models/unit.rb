class Unit < ActiveRecord::Base
  validates :abbreviation, presence: true
  validates :name, presence: true

  has_many :physical_objects

  def display_name
    self.abbreviation + ": " + self.name
  end

end
