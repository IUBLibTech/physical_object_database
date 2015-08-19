class DigitalFileProvenanceSignalChain < ActiveRecord::Migration
  def up
  	remove_column :digital_file_provenances, :player_serial_number
    remove_column :digital_file_provenances, :player_manufacturer
    remove_column :digital_file_provenances, :player_model
    remove_column :digital_file_provenances, :ad_serial_number
    remove_column :digital_file_provenances, :ad_manufacturer
    remove_column :digital_file_provenances, :ad_model
    remove_column :digital_file_provenances, :extraction_workstation

    add_column :digital_file_provenances, :signal_chain_id, :integer, limit: 8
    add_index :digital_file_provenances, :signal_chain_id
  end

  def down
  	add_column :digital_file_provenances, :player_serial_number, :string
    add_column :digital_file_provenances, :player_manufacturer, :string
    add_column :digital_file_provenances, :player_model, :string
    add_column :digital_file_provenances, :ad_serial_number, :string
    add_column :digital_file_provenances, :ad_manufacturer, :string
    add_column :digital_file_provenances, :ad_model, :string
    add_column :digital_file_provenances, :extraction_workstation, :string

    remove_column :digital_file_provenances, :signal_chain_id
  end
end
