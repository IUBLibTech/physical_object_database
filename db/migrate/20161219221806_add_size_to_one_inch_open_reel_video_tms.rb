class AddSizeToOneInchOpenReelVideoTms < ActiveRecord::Migration
  def change
    add_column :one_inch_open_reel_video_tms, :size, :string
  end
end
