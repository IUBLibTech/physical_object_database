class CreateWorkflowStatuses < ActiveRecord::Migration
  def change
    create_table :workflow_statuses do |t|
    	t.integer :workflow_status_template_id
    	t.integer :condition_status_template_id
    	t.integer :physical_object_id
    	t.integer :batch_id
    	t.integer :bin_id
    	t.text :notes
    	#the order that a given status was applied to an object - this is not the sequence from the template
    	t.integer :order
      t.timestamps
    end
  end
end
