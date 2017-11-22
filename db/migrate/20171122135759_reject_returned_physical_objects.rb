class RejectReturnedPhysicalObjects < ActiveRecord::Migration
  def up
    puts "Updating #{PhysicalObject.where(workflow_status: ['Unpacked', 'Returned to Unit'], digital_workflow_category: 0).count} records"
    PhysicalObject.where(workflow_status: ['Unpacked', 'Returned to Unit'], digital_workflow_category: [0, nil]).update_all(digital_workflow_category: 5)
  end
  def down
    puts "No action on rollback"
  end
end
