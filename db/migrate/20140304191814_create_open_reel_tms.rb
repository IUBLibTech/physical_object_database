class CreateOpenReelTms < ActiveRecord::Migration
  def change
    create_table :open_reel_tms do |t|
    	t.string :pack_deformation
    	t.string :preservation_problem
    	t.string :reel_size
    	t.string :playback_speed
    	t.string :track_configuration
    	t.string :tape_thickness
    	t.string :sound_field
    	t.string :tape_stock_brand
    	t.string :tape_base
    	t.date :year_of_recording
    	t.string :directions_recorded
      t.timestamps
    end
  end
end
