class AddAspectRatiosToFilmTm < ActiveRecord::Migration
  def change
    add_column :film_tms, :one_point36, :boolean
    add_column :film_tms, :one_point18, :boolean
  end
end
