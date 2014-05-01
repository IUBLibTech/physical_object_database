class AddConditionStatuses < ActiveRecord::Migration
  def change
    create_table :condition_statuses do |t|
      t.integer	:condition_status_template_id
      t.integer	:physical_object_id
      t.text	:notes 

      t.timestamps
    end
  end
end
