class AddWorkflowIndexToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :workflow_index, :integer
  end
end
