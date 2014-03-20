class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.string :identifier
      t.string :name
      t.text :description
      t.string :batch_status
      t.timestamps
    end
  end
end
