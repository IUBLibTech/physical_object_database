class Unit < ActiveRecord::Base
  default_scope { order(:abbreviation) }
  validates :abbreviation, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  has_many :physical_objects, dependent: :restrict_with_error
  has_many :users

  after_initialize :default_values, if: :new_record?

  def home
    institution.to_s + (institution.to_s.blank? ? "" : "-") + campus.to_s
  end

  def spreadsheet_descriptor
    abbreviation
  end

  def default_values
    self.institution ||= 'Indiana University'
    self.campus ||= 'Bloomington'
  end
end
