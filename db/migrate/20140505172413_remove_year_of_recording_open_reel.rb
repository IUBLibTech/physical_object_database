class RemoveYearOfRecordingOpenReel < ActiveRecord::Migration
  
  def up
  	remove_column :open_reel_tms, :year_of_recording
  end

  def down
  	add_column :open_reel_tms, :year_of_recording
  end
end
