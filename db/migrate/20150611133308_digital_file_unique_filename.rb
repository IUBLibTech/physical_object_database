class DigitalFileUniqueFilename < ActiveRecord::Migration
  def up
  	add_index :digital_files, :filename, unique: true
  end

  def down
  	remove_index :digital_files, column: :filename
  end
end
