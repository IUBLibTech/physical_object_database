class DigitalFileProvenanceNewDatFields < ActiveRecord::Migration
  def change
    add_column :digital_file_provenances, :sample_rate, :string
    add_column :digital_file_provenances, :digital_to_analog, :boolean
  end
end
