class CreateBins < ActiveRecord::Migration
  def change
    create_table :bins do |t|
      t.integer :batch_id
      t.integer :barcode, :limit => 8
      t.integer :picklist_specification_id, limit: 8
      t.string :identifier, :null => false, :unique => true #apparently rails doesn't support unique...
      t.text :description
      t.integer :batch_id
      t.string :status
      t.timestamps
    end
  end
end
