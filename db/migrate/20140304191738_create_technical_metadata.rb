class CreateTechnicalMetadata < ActiveRecord::Migration

  def change
    create_table :technical_metadata, as_relation_superclass: true do |t|
    	t.integer :physical_object_id, :limit => 8
    	t.integer :picklist_specification_id, :limit => 8
      t.timestamps
    end
  end
end
