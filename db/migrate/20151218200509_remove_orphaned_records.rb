class RemoveOrphanedRecords < ActiveRecord::Migration
  def up
    puts "Deleting orphaned records (by parent death):"
      ["condition_statuses", "digital_provenances", "digital_statuses", "notes", "technical_metadata", "workflow_statuses"].each do |table|
        puts table
        query = "DELETE d from #{table} d LEFT JOIN physical_objects ON physical_objects.id = d.physical_object_id WHERE physical_objects.id IS NULL AND d.physical_object_id IS NOT NULL;"
        ActiveRecord::Base.connection.execute(query)
      end

    puts "Deleting orphaned records (by lack of parent):"
      ["digital_provenances", "digital_statuses", "notes"].each do |table|
        puts table
        query = "DELETE d from #{table} d WHERE d.physical_object_id IS NULL;"
        ActiveRecord::Base.connection.execute(query)
      end
      ["condition_statuses"].each do |table|
        puts table
        query = "DELETE d from #{table} d WHERE d.physical_object_id IS NULL AND d.bin_id IS NULL;"
        ActiveRecord::Base.connection.execute(query)
      end
      ["technical_metadata"].each do |table|
        puts table
        query = "DELETE d from #{table} d WHERE d.physical_object_id IS NULL AND d.picklist_specification_id IS NULL;"
        ActiveRecord::Base.connection.execute(query)
      end
      ["workflow_statuses"].each do |table|
        puts table
        query = "DELETE d from #{table} d WHERE d.physical_object_id IS NULL AND d.batch_id IS NULL AND d.bin_id IS NULL;"
        ActiveRecord::Base.connection.execute(query)
      end
  
    puts "Technical Metadata (specific)"
    ["analog_sound_disc_tms", "betacam_tms", 'cassette_tape_tms', 'cdr_tms', 'compact_disc_tms', 'dat_tms', 'eight_millimeter_video_tms', 'open_reel_tms', 'umatic_video_tms'].each do |specific|
      puts "\t#{specific}"
      query = "DELETE d from #{specific} d LEFT JOIN technical_metadata ON technical_metadata.actable_id = d.id WHERE technical_metadata.id IS NULL;"
      ActiveRecord::Base.connection.execute(query)
    end
  end

  def down
    puts "No action on rollback."
  end
end
