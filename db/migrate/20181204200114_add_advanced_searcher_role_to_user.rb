class AddAdvancedSearcherRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :advanced_searcher, :boolean
  end
end
