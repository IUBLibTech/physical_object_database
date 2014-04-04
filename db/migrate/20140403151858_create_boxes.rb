class CreateBoxes < ActiveRecord::Migration
  def up
    create_table :boxes do |t|
    	t.integer :bin_id, limit: 8
    	t.integer :mdpi_barcode, limit: 8
      t.timestamps
    end
  end

  def down
  	drop_table :boxes
  end
end
