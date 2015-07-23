class DeleteEmptyGroupKeys < ActiveRecord::Migration
  def up
    puts "Checking #{GroupKey.all.count} Group Keys."
    delete_count = 0
    GroupKey.all.each do |group_key|
      if group_key.physical_objects.count.zero?
        group_key.destroy
	delete_count += 1
        print "."
      end
    end
    print "\n"
    puts "Finished.  #{delete_count} empty Group Key(s) deleted."
  end
  def down
    puts "(No rollback action; cannot re-create empty group keys.)"
  end
end
