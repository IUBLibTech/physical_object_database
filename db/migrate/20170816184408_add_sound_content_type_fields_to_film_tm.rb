class AddSoundContentTypeFieldsToFilmTm < ActiveRecord::Migration
  def change
    add_column :film_tms, :music_track, :boolean
    add_column :film_tms, :effects_track, :boolean
    add_column :film_tms, :composite_track, :boolean
    add_column :film_tms, :dialog, :boolean
    add_column :film_tms, :outtakes, :boolean
  end
end
