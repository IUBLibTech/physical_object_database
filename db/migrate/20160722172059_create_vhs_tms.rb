class CreateVhsTms < ActiveRecord::Migration
  def change
    create_table :vhs_tms do |t|
      t.string :format_version
      t.string :recording_standard
      t.string :tape_stock_brand
      t.string :format_duration
      t.string :playback_speed
      t.string :size
      t.string :image_format
      t.string :pack_deformation
      t.boolean :damaged_tape
      t.boolean :damaged_shell
      t.boolean :fungus
      t.boolean :soft_binder_syndrome
      t.boolean :other_contaminants

      t.timestamps null: false
    end
  end
end
