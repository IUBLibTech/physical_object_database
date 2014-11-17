class DropCountCacheFromGroupKeys < ActiveRecord::Migration
  def up
    remove_column :group_keys, :physical_objects_count
  end
  def down
    add_column :group_keys, :physical_objects_count, :integer, null: false, default: 0
  end
end
