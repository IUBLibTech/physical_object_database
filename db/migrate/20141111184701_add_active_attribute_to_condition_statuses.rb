class AddActiveAttributeToConditionStatuses < ActiveRecord::Migration
  def up
  	add_column :condition_statuses, :active, :boolean
  end

  def down
  	remove column :condition_statuses, :active
  end
end
