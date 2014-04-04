class CreatePhysicalObjects < ActiveRecord::Migration
  def up
    create_table :physical_objects do |t|
      t.integer :bin_id
      t.integer :box_id, limit: 8
      t.integer :picklist_id, limit: 8
      t.integer :container_id, limit: 8
      t.integer :memnon_barcode, limit: 8
      t.integer :iu_barcode, limit: 8
      t.string :shelf_number
      t.string :call_number
      t.string :title_control_number
      t.text :title
      t.string :format
      t.string :unit
      t.string :collection_id
      t.string :collection_name
      t.string :primary_location
      t.string :secondary_location
      t.string :composer_performer
      t.string :generation
      t.string :duration
      t.string :duration_type
      t.integer :carrier_stream_index, :default => 0
      #whether or not the original recording container has additional media 
      #associated with it (programs, notes, etc)
      t.boolean :has_media
      t.timestamps
    end
  end
  
  def down
    drop_table :physical_objects
  end
end
