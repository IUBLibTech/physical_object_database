class UpdateDigitalProvenanceFields < ActiveRecord::Migration
  def up
  	remove_column :digital_provenances, :created_by
  	remove_column :digital_provenances, :player_serial_number
  	remove_column :digital_provenances, :player_manufacturer
  	remove_column :digital_provenances, :player_model
  	remove_column :digital_provenances, :ad_serial_number
  	remove_column :digital_provenances, :ad_manufacturer
  	remove_column :digital_provenances, :ad_model
  	remove_column :digital_provenances, :extraction_workstation
  	remove_column :digital_provenances, :speed_used

  	# moving digital file provenance into a constituent of digital provenance and removing digital files altogether.
  	remove_column :digital_file_provenances, :digital_file_id
  	add_column :digital_file_provenances, :digital_provenance_id, :integer, limit: 8

  	drop_table :digital_files
  end

  def down
  	add_column :digital_provenances, :created_by, :string
  	add_column :digital_provenances, :player_serial_number, :string
  	add_column :digital_provenances, :player_manufacturer, :string
  	add_column :digital_provenances, :player_model, :string
  	add_column :digital_provenances, :ad_serial_number, :string
  	add_column :digital_provenances, :ad_manufacturer, :string
  	add_column :digital_provenances, :ad_model, :string
  	add_column :digital_provenances, :extraction_workstation, :string
  	add_column :digital_provenances, :speed_used, :string

  	add_column :digital_file_provenances, :digital_file_id, :integer, limit: 8
  	remove_column :digital_file_provenances, :digital_provenance_id

  	create_table :digital_files do |t|
    	t.integer :physical_object_id, limit: 8
    	t.string :filename
      #preservation master, production master, etc
      t.string :role
    	t.string :format
    	t.text :description
      t.timestamps
    end

  end
end
