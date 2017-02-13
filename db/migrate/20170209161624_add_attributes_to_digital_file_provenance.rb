class AddAttributesToDigitalFileProvenance < ActiveRecord::Migration
  def change
    add_column :digital_file_provenances, :rumble_filter, :integer
    add_column :digital_file_provenances, :reference_tone_frequency, :integer
  end
end
