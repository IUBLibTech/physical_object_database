class AddDigitalStartTimestampToPhysicalObject < ActiveRecord::Migration
  def up
  	add_column :physical_objects, :digital_start, :datetime
  end

  def down
  	remove_column :physical_objects, :digital_start
  end
end
