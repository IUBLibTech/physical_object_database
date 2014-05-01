class DropStatusFieldsFromBinAndBatch < ActiveRecord::Migration
  def change
    remove_column :batches, :batch_status
    remove_column :bins, :status
  end
end
