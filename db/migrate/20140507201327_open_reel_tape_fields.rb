class OpenReelTapeFields < ActiveRecord::Migration
  def up
  	# track configuration fields
  	add_column :open_reel_tms, :full_track, :boolean
  	add_column :open_reel_tms, :half_track, :boolean
  	add_column :open_reel_tms, :quarter_track, :boolean
  	add_column :open_reel_tms, :unknown_track, :boolean
  	remove_column :open_reel_tms, :track_configuration

  	# tape thickness fields
  	add_column :open_reel_tms, :zero_point5_mils, :boolean
  	add_column :open_reel_tms, :one_mils, :boolean
  	add_column :open_reel_tms, :one_point5_mils, :boolean
  	remove_column :open_reel_tms, :tape_thickness

  	# sound field fields
  	add_column :open_reel_tms, :mono, :boolean
  	add_column :open_reel_tms, :stereo, :boolean
  	add_column :open_reel_tms, :unknown_sound_field, :boolean
  	remove_column :open_reel_tms, :sound_field

  	# tape base
  	add_column :open_reel_tms, :acetate_base, :boolean
  	add_column :open_reel_tms, :polyester_base, :boolean
  	add_column :open_reel_tms, :pvc_base, :boolean
  	add_column :open_reel_tms, :paper_base, :boolean
  	remove_column :open_reel_tms, :tape_base

    # playback speed - missed this one in previous migration
    add_column :open_reel_tms, :unknown_playback_speed, :boolean

    # directions recorded
    add_column :open_reel_tms, :one_direction, :boolean
    add_column :open_reel_tms, :two_directions, :boolean
    add_column :open_reel_tms, :unknown_direction, :boolean
    remove_column :open_reel_tms, :directions_recorded

  end

  def down
    # directions recorded
    add_column :open_reel_tms, :directions_recorded, :string
    remove_column :open_reel_tms, :unknown_direction
    remove_column :open_reel_tms, :two_directions
    remove_column :open_reel_tms, :one_direction

    # playback speed - missed this one in previous migration
    remove_column :open_reel_tms, :unknown_playback_speed

  	# tape base
  	add_column :open_reel_tms, :tape_base, :string
  	remove_column :open_reel_tms, :paper_base
  	remove_column :open_reel_tms, :pvc_base
  	remove_column :open_reel_tms, :polyester_base
  	remove_column :open_reel_tms, :acetate_base

  	# sound field fields
  	add_column :open_reel_tms, :sound_field, :string
  	remove_column :open_reel_tms, :unknown_sound_field
  	remove_column :open_reel_tms, :stereo
  	remove_column :open_reel_tms, :mono

  	# tape thickness fields
  	add_column :open_reel_tms, :tape_thickness, :string
  	remove_column :open_reel_tms, :one_point5_mils
  	remove_column :open_reel_tms, :one_mils
  	remove_column :open_reel_tms, :zero_point5_mils
 
   	# track configuration fields
  	add_column :open_reel_tms, :track_configuration, :string
  	remove_column :open_reel_tms, :unknown_track
  	remove_column :open_reel_tms, :quarter_track
  	remove_column :open_reel_tms, :half_track
  	remove_column :open_reel_tms, :full_track
  end
end
