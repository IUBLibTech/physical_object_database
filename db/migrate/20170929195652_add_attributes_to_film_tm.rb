class AddAttributesToFilmTm < ActiveRecord::Migration
  def change
    add_column :film_tms, :other_generation, :boolean
    add_column :film_tms, :narration, :boolean
  end
end
