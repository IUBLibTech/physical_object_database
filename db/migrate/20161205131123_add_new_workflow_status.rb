class AddNewWorkflowStatus < ActiveRecord::Migration
  def up
    Rake::Task['db:workflow_status_data'].invoke('add')
  end
  def down
    puts "Removing new workflow status"
    WorkflowStatusTemplate.where(name: 'Re-send to Memnon').destroy_all
  end
end
