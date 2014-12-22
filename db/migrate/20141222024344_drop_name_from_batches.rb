class DropNameFromBatches < ActiveRecord::Migration
  def up
    remove_column :batches, :name
  end
  def down
    add_column :batches, :name, :string
  end
end
