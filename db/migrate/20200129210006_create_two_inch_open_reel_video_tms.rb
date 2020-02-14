class CreateTwoInchOpenReelVideoTms < ActiveRecord::Migration
  def change
    create_table :two_inch_open_reel_video_tms do |t|
      t.string :recording_standard
      t.string :format_duration
      t.string :reel_type
      t.string :format_version
      t.string :recording_mode
      t.string :tape_stock_brand
      t.string :pack_deformation
      t.string :structural_damage
      t.boolean :fungus
      t.boolean :soft_binder_syndrome
      t.boolean :other_contaminants
      t.boolean :foam_with_seepage
      t.boolean :foam_without_seepage

      t.timestamps null: false
    end
  end
end
