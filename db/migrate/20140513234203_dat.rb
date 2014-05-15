class Dat < ActiveRecord::Migration
  def up
  	rename_column :dat_tms, :stock_brand, :tape_stock_brand
  end

  def down
  	rename_column :dat_tms, :tape_stock_brand, :stock_brand
  end
end
