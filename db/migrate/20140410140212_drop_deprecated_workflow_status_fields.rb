class DropDeprecatedWorkflowStatusFields < ActiveRecord::Migration
  def change
    remove_column :workflow_statuses, :condition_status_template_id, :integer
    remove_column :workflow_statuses, :order, :integer
  end
end

