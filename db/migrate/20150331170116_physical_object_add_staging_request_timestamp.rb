class PhysicalObjectAddStagingRequestTimestamp < ActiveRecord::Migration
  def up
  	add_column :physical_objects, :staging_request_timestamp, :datetime
  end

  def down
  	remove_column :physical_objects, :staging_request_timestamp
  end
end
