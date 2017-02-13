class CreateCylinderTm < ActiveRecord::Migration
  def change
    create_table :cylinder_tms do |t|
      t.string :size
      t.string :material
      t.string :groove_pitch
      t.string :playback_speed
      t.string :recording_method
      t.boolean :fragmented
      t.boolean :repaired_break
      t.boolean :cracked
      t.boolean :damaged_core
      t.boolean :fungus
      t.boolean :efflorescence
      t.boolean :other_contaminants
    end
  end
end
