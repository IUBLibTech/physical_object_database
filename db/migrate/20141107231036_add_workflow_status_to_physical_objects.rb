class AddWorkflowStatusToPhysicalObjects < ActiveRecord::Migration
  def change
    add_column :physical_objects, :workflow_status, :string
    add_index :physical_objects, :workflow_status
  end
end
