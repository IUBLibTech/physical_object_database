class PhysicalObjectAddStagingFlags < ActiveRecord::Migration
  def up
  	add_column :physical_objects, :staging_requested, :boolean, default: false 
  	add_column :physical_objects, :staged, :boolean, default: false
  end

  def down
  	remove_column :physical_objects, :staging_requested
  	remove_column :physical_objects, :staged
  end
end
