class CreateAnalogSoundDiscImagingTms < ActiveRecord::Migration
  def change
    create_table :analog_sound_disc_imaging_tms do |t|
      t.string :subtype
      t.string :diameter
      t.string :speed
      t.string :groove_size
      t.string :groove_orientation
      t.string :recording_method
      t.string :material
      t.string :substrate
      t.string :coating
      t.string :equalization
      t.string :country_of_origin
      t.string :label
      t.string :sound_field
      t.boolean :delamination
      t.boolean :exudation
      t.boolean :oxidation
      t.boolean :cracked
      t.boolean :warped
      t.boolean :dirty
      t.boolean :scratched
      t.boolean :worn
      t.boolean :broken
      t.boolean :fungus

      t.timestamps null: false
    end
  end
end
