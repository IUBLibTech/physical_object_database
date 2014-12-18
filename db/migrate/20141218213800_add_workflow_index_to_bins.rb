class AddWorkflowIndexToBins < ActiveRecord::Migration
  def change
    add_column :bins, :workflow_index, :integer
    add_index :bins, [:workflow_index, :identifier]
  end
end
