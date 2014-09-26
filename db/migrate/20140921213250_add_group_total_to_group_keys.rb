class AddGroupTotalToGroupKeys < ActiveRecord::Migration
  def change
    add_column :group_keys, :group_total, :integer
  end
end
