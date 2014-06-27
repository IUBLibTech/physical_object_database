class DropStatusFieldsFromBinAndBatch < ActiveRecord::Migration
  def change
    remove_column :batches, :batch_status, :string
    remove_column :bins, :status, :string
  end
end
