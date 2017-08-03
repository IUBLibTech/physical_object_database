class AddStockValuesToFilmTm < ActiveRecord::Migration
  def change
    add_column :film_tms, :stock_three_m, :boolean
    add_column :film_tms, :stock_agfa_gevaert, :boolean
    add_column :film_tms, :stock_pathe, :boolean
    add_column :film_tms, :stock_unknown, :boolean
  end
end
