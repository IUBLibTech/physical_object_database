class CreatePhysicalObjectWorkflowStatuses < ActiveRecord::Migration
  def change
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
