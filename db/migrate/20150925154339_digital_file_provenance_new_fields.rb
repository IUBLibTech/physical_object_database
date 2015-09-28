class DigitalFileProvenanceNewFields < ActiveRecord::Migration
  def change
  	add_column :digital_file_provenances, :tape_fluxivity, :integer
  	add_column :digital_file_provenances, :volume_units, :string
  	add_column :digital_file_provenances, :analog_output_voltage, :string
  	add_column :digital_file_provenances, :peak, :integer
  end
end
