class Unit < ActiveRecord::Base
  validates :abbreviation, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  has_many :physical_objects

  def home
    institution.to_s + (institution.to_s.blank? ? "" : ", ") + campus.to_s
  end

  def spreadsheet_descriptor
    abbreviation
  end
end
