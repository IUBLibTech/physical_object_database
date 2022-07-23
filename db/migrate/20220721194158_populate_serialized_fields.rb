class PopulateSerializedFields < ActiveRecord::Migration
  def up
    puts "Populating MemnonInvoiceSubmission: #{MemnonInvoiceSubmission.count}"
    MemnonInvoiceSubmission.find_in_batches.with_index do |group, batch|
      puts "processing batch #{batch}"
      group.each_with_index do |mis, i|
        puts "#{i+1}: #{mis.id}"
        mis.problems_by_row_json = mis.problems_by_row
        mis.save!
      end
    end
    puts "Populating DigitalStatus: #{DigitalStatus.count}"
    DigitalStatus.find_in_batches.with_index do |group, batch|
      puts "processing batch #{batch}"
      group.each_with_index do |ds, i|
        puts "#{i+1}: #{ds.id}"
        ds.options_json = ds.options
        ds.save! 
      end
    end
  end
  def down
    puts "no action on rollback"
  end
end
