class AddCountAndDropIdentifierOnGroupKey < ActiveRecord::Migration
  def up
    remove_column :group_keys, :identifier
    add_column :group_keys, :physical_objects_count, :integer, null: false, default: 0
  end
  def down
    add_column :group_keys, :identifier, :string
    remove_column :group_keys, :physical_objects_count
  end
end
