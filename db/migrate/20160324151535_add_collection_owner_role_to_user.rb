class AddCollectionOwnerRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :collection_owner, :boolean
  end
end
