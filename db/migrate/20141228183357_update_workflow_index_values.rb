class UpdateWorkflowIndexValues < ActiveRecord::Migration
  # seed initial workflow_index values
  def up
    update_objects = PhysicalObject.where(workflow_index: nil) + Bin.where(workflow_index: nil) + Batch.where(workflow_index: nil)
    update_objects.each do |object|
      if object.workflow_index.nil?
        object.workflow_index = object.workflow_statuses.last.workflow_status_template.sequence_index
        object.save
      end
    end
    puts "#{update_objects.size} objects updated"
  end

  # no action necessary
  def down
    puts "no action necessary"
  end
end

