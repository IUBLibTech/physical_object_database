class CreateDvTms < ActiveRecord::Migration
  def change
    create_table :dv_tms do |t|
      t.string :recording_standard
      t.string :format_duration
      t.string :image_format
      t.string :variant
      t.string :size
      t.string :stock_brand
      t.boolean :breakdown_of_materials
      t.boolean :fungus
      t.boolean :other_contaminants
      t.string :damage
      t.string :playback_speed

      t.timestamps null: false
    end
  end
end
