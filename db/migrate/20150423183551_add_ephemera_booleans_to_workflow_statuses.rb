class AddEphemeraBooleansToWorkflowStatuses < ActiveRecord::Migration
  def up
    add_column :workflow_statuses, :has_ephemera, :boolean
    add_column :workflow_statuses, :ephemera_returned, :boolean
    add_column :workflow_statuses, :ephemera_okay, :boolean
 
    puts "Updating #{PhysicalObject.all.size} objects' workflow statuses (with regards to ephemera values)..."
    PhysicalObject.all.each do |po|
      if po.workflow_statuses.any?
        ws = po.workflow_statuses.last 
        ws.set_ephemera_values
        ws.save!
	print "#{po.id},"
      else
        print "#{po.id} SKIPPED,"
      end
    end
    puts "Done!"
  end

  def down
    remove_column :workflow_statuses, :has_ephemera
    remove_column :workflow_statuses, :ephemera_returned
    remove_column :workflow_statuses, :ephemera_okay
  end
end
