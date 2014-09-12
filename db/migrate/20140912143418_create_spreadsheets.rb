class CreateSpreadsheets < ActiveRecord::Migration
  def change
    create_table :spreadsheets do |t|
      t.string :filename
      t.text :note

      t.timestamps
    end
    add_index :spreadsheets, :filename, unique: true
  end
end
