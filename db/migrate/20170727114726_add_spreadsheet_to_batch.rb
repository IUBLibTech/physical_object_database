class AddSpreadsheetToBatch < ActiveRecord::Migration
  def change
    add_reference :batches, :spreadsheet, index: true, foreign_key: true
  end
end
