class AddStatusIndexes < ActiveRecord::Migration
  def change
    add_index :workflow_status_templates, [:object_type, :sequence_index], name: :index_wst_on_object_type_and_sequence_index

    add_index :workflow_statuses, [:batch_id, :workflow_status_template_id], name: :index_ws_on_batch_and_wst
    add_index :workflow_statuses, [:bin_id, :workflow_status_template_id], name: :index_ws_on_bin_and_wst
    add_index :workflow_statuses, [:physical_object_id, :workflow_status_template_id], name: :index_ws_on_po_and_wst

    add_index :condition_status_templates, [:object_type, :name], name: :index_cst_on_object_and_name

  end
end
