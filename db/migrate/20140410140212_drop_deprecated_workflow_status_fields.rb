class DropDeprecatedWorkflowStatusFields < ActiveRecord::Migration
  def change
    remove_column :workflow_statuses, :condition_status_template_id
    remove_column :workflow_statuses, :order
  end
end

