class AddCompleteStateToPicklist < ActiveRecord::Migration
  def up
  	add_column :picklists, :complete, :boolean, default: false
  end

  def down
  	remove_column :picklists, :complete
  end
end
