class CreateDigitalStatuses < ActiveRecord::Migration
  def up
    create_table :digital_statuses do |t|
    	t.integer :physical_object_id
      t.integer :physical_object_mdpi_barcode, limit: 8
    	t.string :state
      t.text :message
      t.boolean :accepted
    	t.boolean :attention
    	t.text :decided
    	t.text :options 
      t.timestamps
    end
  end

  def down
  	drop_table :digital_statuses
  end
end
