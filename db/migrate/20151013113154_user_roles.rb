class UserRoles < ActiveRecord::Migration
  def change
  	add_column :users, :smart_team_user, :boolean
  	add_column :users, :smart_team_admin, :boolean
  	add_column :users, :qc_user, :boolean
  	add_column :users, :qc_admin, :boolean
  	add_column :users, :web_admin, :boolean
  end
end
