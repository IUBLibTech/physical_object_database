class AddSpreadsheetToBox < ActiveRecord::Migration
  def change
    add_reference :boxes, :spreadsheet, index: true
  end
end
