class AddWorkflowStatusToBins < ActiveRecord::Migration
  def change
    add_column :bins, :workflow_status, :string
    add_index :bins, :workflow_status
  end
end
