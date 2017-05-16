class Unit < ActiveRecord::Base
  default_scope { order(:abbreviation) }
  validates :abbreviation, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: { scope: [:institution, :campus] }

  has_many :physical_objects, dependent: :restrict_with_error
  has_many :users

  after_initialize :default_values, if: :new_record?

  def home
    home_text = ""
    home_text = institution.to_s + (institution.to_s.blank? ? "" : " ") + campus.to_s
    home_text
  end

  def spreadsheet_descriptor
    abbreviation
  end

  def default_values
    self.institution ||= 'Indiana University'
    self.campus ||= 'Bloomington'
  end
end
