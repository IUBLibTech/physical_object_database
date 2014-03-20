class CreatePhysicalObjects < ActiveRecord::Migration
  def up
    create_table :physical_objects do |t|
      t.integer :bin_id
      t.integer :memnon_barcode, :limit => 8
      t.integer :iu_barcode, :limit => 8
      t.string :shelf_number
      t.string :call_number
      t.text :title
      t.string :format
      t.string :unit
      t.string :collection_id
      t.string :primary_location
      t.string :secondary_location
      t.string :composer_performer
      t.integer :sequence, :default => 0
      t.timestamps
    end
  end
  
  def down
    drop_table :physical_objects
  end
end
