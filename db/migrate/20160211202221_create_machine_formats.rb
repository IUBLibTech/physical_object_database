class CreateMachineFormats < ActiveRecord::Migration
  def change
    create_table :machine_formats do |t|
      t.references :machine, index: true
      t.string :format

      t.timestamps
    end
  end
end
