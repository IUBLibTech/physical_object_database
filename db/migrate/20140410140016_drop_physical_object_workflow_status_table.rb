class DropPhysicalObjectWorkflowStatusTable < ActiveRecord::Migration
  def up
    drop_table :physical_object_workflow_statuses
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover deleted table"
  end
end
