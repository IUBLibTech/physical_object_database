class AddWorkflowIndexToPhysicalObjects < ActiveRecord::Migration
  def change
    add_column :physical_objects, :workflow_index, :integer
  end
end
