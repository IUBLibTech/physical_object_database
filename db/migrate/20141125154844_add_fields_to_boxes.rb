class AddFieldsToBoxes < ActiveRecord::Migration
  def up
    add_column :boxes, :full, :boolean, default: false
    add_column :boxes, :description, :text
    Box.connection.execute("UPDATE boxes SET description = '' WHERE description IS NULL")
  end
  def down
    remove_column :boxes, :full
    remove_column :boxes, :description
  end
end
