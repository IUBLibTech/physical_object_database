class CreateWorkflowStatusTemplates < ActiveRecord::Migration
  def change
    create_table :workflow_status_templates do |t|
    	t.string :name
    	t.text :description
    	t.integer :sequence_index
    	t.string :object_type
      t.timestamps
    end

    # add_index :workflow_status_templates, :name, unique: true

  end
end
