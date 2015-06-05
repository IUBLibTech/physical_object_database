class CreateDigitalProvenances < ActiveRecord::Migration
  def up
    create_table :digital_provenances do |t|
    	t.string :digitizing_entity
    	t.datetime :date
    	t.text :comments
    	t.string :created_by
    	t.datetime :cleaning_date
    	t.string :player_serial_number
    	t.string :player_manufacturer
    	t.string :player_model
    	t.string :ad_serial_number
    	t.string :ad_manufacturer
    	t.string :ad_model
    	t.datetime :baking
    	t.boolean :repaired
    	t.string :extraction_workstation
      t.string :speed_used
      t.integer :physical_object_id, limit: 8
      t.timestamps
    end
  end

  def down
  	drop_table :digital_provenances
  end
end
