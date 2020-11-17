class CreateMagnabeltTms < ActiveRecord::Migration
  def change
    create_table :magnabelt_tms do |t|
      t.string :size
      t.string :stock_brand
      t.string :damage

      t.timestamps null: false
    end
  end
end
