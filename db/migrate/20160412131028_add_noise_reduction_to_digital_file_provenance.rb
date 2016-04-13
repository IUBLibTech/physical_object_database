class AddNoiseReductionToDigitalFileProvenance < ActiveRecord::Migration
  def change
    add_column :digital_file_provenances, :noise_reduction, :string
  end
end
