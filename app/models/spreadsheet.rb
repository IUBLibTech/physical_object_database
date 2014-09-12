#
# Object for an uploaded spreadsheet
#
class Spreadsheet < ActiveRecord::Base

  validates :filename, presence: true, uniqueness: true

end
