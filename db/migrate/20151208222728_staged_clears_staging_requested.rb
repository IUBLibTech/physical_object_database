class StagedClearsStagingRequested < ActiveRecord::Migration
  def up
    PhysicalObject.where(staging_requested: true, staged: true).update_all(staging_requested: false)
  end

  def down
    # nothing that can be undone
  end
end
