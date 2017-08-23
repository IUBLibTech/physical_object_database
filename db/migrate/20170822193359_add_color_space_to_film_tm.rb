class AddColorSpaceToFilmTm < ActiveRecord::Migration
  def change
    add_column :film_tms, :color_space, :string
  end
end
