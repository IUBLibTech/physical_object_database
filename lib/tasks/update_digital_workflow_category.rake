# update_digital_workflow_category.rake
# Rake task to backfill in category value for old objects
#
# Example use:
# rake digital_workflow:update_category
#
namespace :digital_workflow do
  desc "Auto-accept audio and video files past 30/40-day window"
    task :update_category => :environment do |_task, _args|
      print "Updating #{PhysicalObject.where.not(digital_start: nil).where(digital_workflow_category: 0).count} objects:"
      PhysicalObject.where.not(digital_start: nil).where(digital_workflow_category: 0).find_each do |po|
        ds = po.digital_statuses.last
        if ds
          ds.update_physical_object
          print '.'
        else
          print '-'
        end
      end
    end
end
