class CreateBillablePhysicalObjects < ActiveRecord::Migration
  def up
    create_table :billable_physical_objects do |t|
    	t.integer :mdpi_barcode, limit: 8
    	t.datetime :delivery_date
    end
    add_index :billable_physical_objects, :mdpi_barcode, unique: true 
  end

  def down
  	drop_table :billable_physical_objects
  end
end
