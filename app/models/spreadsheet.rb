#
# Object for an uploaded spreadsheet
#
class Spreadsheet < ActiveRecord::Base

  has_many :batches, dependent: :nullify
  has_many :bins
  has_many :boxes
  has_many :physical_objects, dependent: :destroy

  validates :filename, presence: true, uniqueness: true

  def spreadsheet_descriptor
    filename
  end

end
