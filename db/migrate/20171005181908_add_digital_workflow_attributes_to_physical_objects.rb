class AddDigitalWorkflowAttributesToPhysicalObjects < ActiveRecord::Migration
  def change
    add_column :physical_objects, :digital_workflow_status, :string
    add_column :physical_objects, :digital_workflow_category, :integer, default: 0
  end
end
