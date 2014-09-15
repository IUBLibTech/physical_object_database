class AddSpreadsheetToBin < ActiveRecord::Migration
  def change
    add_reference :bins, :spreadsheet, index: true
  end
end
