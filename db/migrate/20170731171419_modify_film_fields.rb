class ModifyFilmFields < ActiveRecord::Migration
  def up
    remove_column :film_tms, :mixed_generation
    remove_column :film_tms, :original_camera
    add_column :film_tms, :two_point66, :boolean
    remove_column :film_tms, :anamorphic
    add_column :film_tms, :anamorphic, :string
    remove_column :film_tms, :mixed_sound_format
    add_column :film_tms, :digital_dolby_a, :boolean
    add_column :film_tms, :digital_dolby_sr, :boolean
    add_column :film_tms, :track_count, :string
    add_column :film_tms, :format_duration, :string
    add_column :film_tms, :stock_agfa, :boolean
    add_column :film_tms, :stock_ansco, :boolean
    add_column :film_tms, :stock_dupont, :boolean
    add_column :film_tms, :stock_orwo, :boolean
    add_column :film_tms, :stock_fuji, :boolean
    add_column :film_tms, :stock_gevaert, :boolean
    add_column :film_tms, :stock_kodak, :boolean
    add_column :film_tms, :stock_ferrania, :boolean
    add_column :film_tms, :conservation_actions, :text
  end
  def down
    add_column :film_tms, :mixed_generation, :boolean
    add_column :film_tms, :original_camera, :boolean
    remove_column :film_tms, :two_point66
    remove_column :film_tms, :anamorphic
    add_column :film_tms, :anamorphic, :boolean
    add_column :film_tms, :mixed_sound_format, :boolean
    remove_column :film_tms, :digital_dolby_a
    remove_column :film_tms, :digital_dolby_sr
    remove_column :film_tms, :track_count
    remove_column :film_tms, :format_duration
    remove_column :film_tms, :stock_agfa
    remove_column :film_tms, :stock_ansco
    remove_column :film_tms, :stock_dupont
    remove_column :film_tms, :stock_orwo
    remove_column :film_tms, :stock_fuji
    remove_column :film_tms, :stock_gevaert
    remove_column :film_tms, :stock_kodak
    remove_column :film_tms, :stock_ferrania
    remove_column :film_tms, :conservation_actions
  end
end
