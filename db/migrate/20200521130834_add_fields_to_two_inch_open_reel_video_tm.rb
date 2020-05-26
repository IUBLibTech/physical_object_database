class AddFieldsToTwoInchOpenReelVideoTm < ActiveRecord::Migration
  def change
    add_column :two_inch_open_reel_video_tms, :cue_track_contains, :string
    add_column :two_inch_open_reel_video_tms, :sound_field, :string
  end
end
