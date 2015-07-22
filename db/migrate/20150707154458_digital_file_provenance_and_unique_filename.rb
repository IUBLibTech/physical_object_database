class DigitalFileProvenanceAndUniqueFilename < ActiveRecord::Migration
  def up
  	add_column :digital_file_provenances, :filename, :string, null: false
  	add_index :digital_file_provenances, :filename, unique: true
  end

  def down
  	remove_column :digital_file_provenances, :filename
  end
end

