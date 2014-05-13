class Unit < ActiveRecord::Base
  validates :abbreviation, presence: true
  validates :name, presence: true

  has_many :physical_objects

  def spreadsheet_descriptor
    abbreviation
  end
end
