class AddWorkflowStatusToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :workflow_status, :string
    add_index :batches, :workflow_status
  end
end
