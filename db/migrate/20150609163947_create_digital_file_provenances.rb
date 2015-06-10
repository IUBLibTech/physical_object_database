class CreateDigitalFileProvenances < ActiveRecord::Migration
  def change
    create_table :digital_file_provenances do |t|
    	t.integer :digital_file_id, limit: 8
    	t.datetime :date_digitized
    	t.text :comment
    	t.string :created_by
    	t.string :player_serial_number
    	t.string :player_manufacturer
    	t.string :player_model
    	t.string :ad_serial_number
    	t.string :ad_manufacturer
    	t.string :ad_model
    	t.string :extraction_workstation
    	t.string :speed_used
      t.timestamps
    end
  end
end
