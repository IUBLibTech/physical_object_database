class CreatePhysicalObjects < ActiveRecord::Migration
  def up
    create_table :physical_objects do |t|
      t.integer :bin_id
      t.integer :box_id, limit: 8
      t.integer :picklist_id, limit: 8
      t.integer :container_id, limit: 8

      t.text :title
      t.string :title_control_number
      t.string :unit
      t.string :home_location
      t.string :call_number
      t.string :shelf_location
      t.integer :iucat_barcode, limit: 8
      t.string :format
      t.integer :carrier_stream_index, :default => 0
      t.string :collection_identifier
      t.integer :mdpi_barcode, limit: 8
      t.string :format_duration
      t.string :content_duration
      # whether or not the original recording container has additional media 
      # associated with it (programs, notes, etc)
      t.boolean :has_ephemira
      t.timestamps
    end
  end
  
  def down
    drop_table :physical_objects
  end
end
