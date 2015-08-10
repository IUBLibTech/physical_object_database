class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :category
      t.string :serial
      t.string :manufacturer
      t.string :model

      t.timestamps
    end
  end
end
