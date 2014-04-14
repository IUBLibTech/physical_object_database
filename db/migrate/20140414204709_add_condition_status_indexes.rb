class AddConditionStatusIndexes < ActiveRecord::Migration
  def change
    add_index :condition_statuses, [:physical_object_id, :condition_status_template_id], name: :index_cs_on_po_and_cst
  end
end
