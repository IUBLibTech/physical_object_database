class AddSpreadsheetToPhysicalObject < ActiveRecord::Migration
  def change
    add_reference :physical_objects, :spreadsheet, index: true
  end
end
