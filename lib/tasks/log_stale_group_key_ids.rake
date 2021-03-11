# log_stale_group_key_ids.rake
# Rake tasks for logging group_key_id values with no GroupKey
#
# Example use:
# rake pod:log_stale_group_key_ids
#
namespace :pod do
  desc "Log stale Group Key IDs"
    task :log_stale_group_key_ids => :environment do |task|
      @logger = Logger.new(Rails.root.join('log', 'stale_group_key_ids.log'), 10, 10.megabytes)
      no_results = true
      PhysicalObject.all.find_in_batches.with_index do |group, batch|
        gkids = group.map(&:group_key_id).sort.uniq
        found = GroupKey.where(id: gkids).map(&:id).sort.uniq
        stale = gkids - found
        if stale.any?
          @logger.info "Stale ids: #{stale}"
          no_results = false
        end
      end
      @logger.info "No stale IDs found" if no_results
    end
end
