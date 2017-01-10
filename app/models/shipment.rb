class Shipment < ActiveRecord::Base
  belongs_to :unit
  has_many :physical_objects
  has_many :picklists
  validates :identifier, presence: true, uniqueness: true
  validates :unit, presence: true

  def picklist_for_format(format)
    picklist = picklists.where(format: format).first
    return picklist if picklist
    picklist = picklists.create(name: "#{identifier} shipment: #{format}", format: format)
  end
end
