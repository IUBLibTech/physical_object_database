class OpenReelTapeTm < ActiveRecord::Migration
  def up
  	add_column :open_reel_tms, :vinegar_syndrome, :boolean
  	add_column :open_reel_tms, :fungus, :boolean
  	add_column :open_reel_tms, :soft_binder_syndrome, :boolean
  	add_column :open_reel_tms, :other_contaminants, :boolean

  	add_column :open_reel_tms, :zero_point9375_ips, :boolean
  	add_column :open_reel_tms, :one_point875_ips, :boolean
  	add_column :open_reel_tms, :three_point75_ips, :boolean
  	add_column :open_reel_tms, :seven_point5_ips, :boolean
  	add_column :open_reel_tms, :fifteen_ips, :boolean
  	add_column :open_reel_tms, :thirty_ips, :boolean 
  	remove_column :open_reel_tms, :playback_speed

  end

  def down
  	add_column :open_reel_tms, :playback_speed, :string
  	remove_column :open_reel_tms, :thirty_ips, :boolean 
  	remove_column :open_reel_tms, :fifteen_ips, :boolean
  	remove_column :open_reel_tms, :seven_point5_ips, :boolean
  	remove_column :open_reel_tms, :three_point75_ips, :boolean
  	remove_column :open_reel_tms, :one_point875_ips, :boolean
  	remove_column :open_reel_tms, :zero_point9375_ips, :boolean

  	remove_column :open_reel_tms, :other_contaminants, :boolean
  	remove_column :open_reel_tms, :soft_binder_syndrome, :boolean
  	remove_column :open_reel_tms, :fungus, :boolean
  	remove_column :open_reel_tms, :vinegar_syndrome, :boolean
  end
end
