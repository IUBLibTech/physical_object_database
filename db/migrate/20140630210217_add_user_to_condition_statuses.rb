class AddUserToConditionStatuses < ActiveRecord::Migration
  def change
    add_column :condition_statuses, :user, :string
  end
end
