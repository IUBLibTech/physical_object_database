# this model represents an entry in Memnon's Invoice spreadsheet. Items in this table are loaded on a per-spreadsheet basis
# and before each load, existing items should first be deleted to minimize join expense
class BillablePhysicalObject < ActiveRecord::Base
end
