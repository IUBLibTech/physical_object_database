class AddEngineerRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :engineer, :boolean
  end
end
