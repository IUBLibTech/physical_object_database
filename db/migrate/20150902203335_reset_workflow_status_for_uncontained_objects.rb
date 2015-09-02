class ResetWorkflowStatusForUncontainedObjects < ActiveRecord::Migration
  def up
    puts "Resetting out-of-sync workflow status on uncontained objects."
    bins = Bin.where(workflow_status: "Batched", batch_id: [0, nil])
    print "#{bins.size} Bins to reset:"
    bins.each do |bin|
      bin.save
      print "."
    end
    print "\n"
    physical_objects = PhysicalObject.where(workflow_status: "Binned", bin_id: [0, nil])
    print "#{physical_objects.size} Un-binned Physical Objects to reset:"
    physical_objects.each do |po|
      po.save
      print "."
    end
    print "\n"
    physical_objects = PhysicalObject.where(workflow_status: "Boxed", box_id: [0, nil])
    print "#{physical_objects.size} Un-boxed Physical Objects to reset:"
    physical_objects.each do |po|
      po.save
      print "."
    end
    print "\n"
  end
  def down
    puts "No action on rollback."
  end
end
