class DigitalFileProvenanceDiscFields < ActiveRecord::Migration
  def change
  	add_column :digital_file_provenances, :stylus_size, :string
  	add_column :digital_file_provenances, :turnover, :string
  	add_column :digital_file_provenances, :rolloff, :string
  end
end
