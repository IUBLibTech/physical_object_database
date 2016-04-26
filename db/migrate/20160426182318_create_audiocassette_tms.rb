class CreateAudiocassetteTms < ActiveRecord::Migration
  def change
    create_table :audiocassette_tms do |t|
      t.string :cassette_type
      t.string :tape_type
      t.string :sound_field
      t.string :tape_stock_brand
      t.string :noise_reduction
      t.string :format_duration
      t.string :pack_deformation
      t.boolean :damaged_tape
      t.boolean :damaged_shell
      t.boolean :zero_point46875_ips
      t.boolean :zero_point9375_ips
      t.boolean :one_point875_ips
      t.boolean :three_point75_ips
      t.boolean :unknown_playback_speed
      t.boolean :fungus
      t.boolean :soft_binder_syndrome
      t.boolean :other_contaminants

      t.timestamps null: false
    end
  end
end
