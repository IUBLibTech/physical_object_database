class CreateFilmTms < ActiveRecord::Migration
  def change
    create_table :film_tms do |t|
      t.string :gauge

      t.timestamps null: false
    end
  end
end
