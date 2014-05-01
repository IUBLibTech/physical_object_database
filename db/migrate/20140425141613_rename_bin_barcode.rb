class RenameBinBarcode < ActiveRecord::Migration
  def up
	rename_column :bins, :barcode, :mdpi_barcode  
  end

  def down
  	rename_column :bins, :mdpi_barcode, :barcode
  end
end
