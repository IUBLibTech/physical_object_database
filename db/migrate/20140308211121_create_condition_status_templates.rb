class CreateConditionStatusTemplates < ActiveRecord::Migration
  def change
    create_table :condition_status_templates do |t|
    	t.string :name
    	t.text :description
    	t.string :object_type
      t.timestamps
    end

    add_index :condition_status_templates, :name, unique: true
  end
end
