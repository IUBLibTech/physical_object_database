class AddExportFlagToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :export, :boolean
  end
end
