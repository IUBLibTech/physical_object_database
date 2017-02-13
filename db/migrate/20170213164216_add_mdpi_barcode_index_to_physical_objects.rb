class AddMdpiBarcodeIndexToPhysicalObjects < ActiveRecord::Migration
  def up
    add_index :physical_objects, :mdpi_barcode
  end
  def down
    remove_index :physical_objects, :mdpi_barcode
  end
end
