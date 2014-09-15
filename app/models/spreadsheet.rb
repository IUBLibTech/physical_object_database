#
# Object for an uploaded spreadsheet
#
class Spreadsheet < ActiveRecord::Base

  has_many :bins, dependent: :destroy
  has_many :boxes, dependent: :destroy
  has_many :physical_objects, dependent: :destroy

  validates :filename, presence: true, uniqueness: true

end
