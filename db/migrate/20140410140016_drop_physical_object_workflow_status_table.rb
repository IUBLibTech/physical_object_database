class DropPhysicalObjectWorkflowStatusTable < ActiveRecord::Migration
  def up
    drop_table :physical_object_workflow_statuses
  end

  def down
    # raise ActiveRecord::IrreversibleMigration, "Can't recover deleted table"
    create_table :physical_object_workflow_statuses do |t|
    	t.integer :physical_object_id, :limit => 8
    	t.integer :workflow_status_template_id, :limit => 8
			t.string :name
    	t.text :notes
    	t.string :object_type
      t.timestamps
    end
  end
end
