class DualMonoOpenReelTm < ActiveRecord::Migration
  def change
    add_column :open_reel_tms, :dual_mono, :boolean
  end
end
