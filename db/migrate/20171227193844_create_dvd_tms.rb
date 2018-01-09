class CreateDvdTms < ActiveRecord::Migration
  def change
    create_table :dvd_tms do |t|
      t.string :recording_standard
      t.string :format_duration
      t.string :image_format
      t.string :dvd_type
      t.string :stock_brand
      t.boolean :breakdown_of_materials
      t.boolean :fungus
      t.boolean :other_contaminants
      t.string :damage
    end
  end
end
