class OpenReelTmDirectionsRecorded < ActiveRecord::Migration
  def up
  	rename_column :open_reel_tms, :directions_recorded, :calculated_directions_recorded
  	add_column :open_reel_tms, :directions_recorded, :integer
  	OpenReelTm.connection.execute("update open_reel_tms set directions_recorded = calculated_directions_recorded")
  end

  def down
  	remove_column :open_reel_tms, :directions_recorded, :integer
  	rename_column :open_reel_tms, :calculated_directions_recorded, :directions_recorded
  end
end
