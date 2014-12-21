class AddUserToWorkflowStatuses < ActiveRecord::Migration
  def up
    add_column :workflow_statuses, :user, :string
    WorkflowStatus.all.update_all(user: "UNAVAILABLE")
  end
  def down
    remove_column :workflow_statuses, :user
  end
end
