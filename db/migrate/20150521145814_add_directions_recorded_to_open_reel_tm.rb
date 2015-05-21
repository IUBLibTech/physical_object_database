class AddDirectionsRecordedToOpenReelTm < ActiveRecord::Migration
  def up
    add_column :open_reel_tms, :directions_recorded, :integer
    remove_column :open_reel_tms, :one_direction
    remove_column :open_reel_tms, :two_directions
    remove_column :open_reel_tms, :unknown_direction

    puts "Updating #{OpenReelTm.all.size} Open Reel Tape records..."
    OpenReelTm.all.each do |tm|
      tm.save!
    end
    puts "Record updates finished."
  end
  def down
    remove_column :open_reel_tms, :directions_recorded
    add_column :open_reel_tms, :one_direction, :boolean
    add_column :open_reel_tms, :two_directions, :boolean
    add_column :open_reel_tms, :unknown_direction, :boolean
  end
end
