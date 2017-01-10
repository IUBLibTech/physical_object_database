class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :identifier
      t.string :description
      t.string :physical_location
      t.references :unit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
