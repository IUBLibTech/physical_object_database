class UpdateBatchWorkflowStatusTemplates < ActiveRecord::Migration
  def up
    if WorkflowStatusTemplate.find_by(name: 'Interim Storage').nil?
      puts "Adding new workflow status"
      WorkflowStatusTemplate.create(name: 'Interim Storage', description: 'The batch has been returned from the digitization facility, but not yet entered receiving area.', sequence_index: 4, object_type: 'Batch')
      returned = WorkflowStatusTemplate.find_by(object_type: 'Batch', name: 'Returned')
      complete = WorkflowStatusTemplate.find_by(object_type: 'Batch', name: 'Complete')
      returned.sequence_index = 5
      returned.description = 'The batch has been returned from the digitization facility, and entered receiving area.'
      returned.save!
      complete.sequence_index = 6
      complete.save!
    else
      puts "Interim Storage status already exists"
    end
  end
  def down
    puts "Removing new workflow status"
    interim = WorkflowStatusTemplate.find_by(object_type: 'Batch', name: 'Interim Storage')
    interim.destroy!
    returned = WorkflowStatusTemplate.find_by(object_type: 'Batch', name: 'Returned')
    complete = WorkflowStatusTemplate.find_by(object_type: 'Batch', name: 'Complete')
    returned.sequence_index = 4
    returned.description = 'The batch has been returned from the digitization facility.'
    returned.save!
    complete.sequence_index = 5
    complete.save!
  end
end
