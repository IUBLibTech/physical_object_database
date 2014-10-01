# Argument options:
# rake db:seed_data || rake db:seed_data[] || rake db:seed_data[default]
#   Attempts to add seed values; aborts on first error
# rake db:seed_data[add]
#   Adds new values, ignoring any errors
# rake db:seed_data[reseed]
#   Wipes existing seed values, re-adds
#
require 'csv'

def seed_units(type = "default")
  puts "Seeding Unit data."
  units_csv = CSV.parse(File.read('lib/tasks/units_values.csv'), headers: true)
  added_count = 0
  skipped_count = 0
  units_csv.each do |unit|
    begin
      result = Unit.create!(abbreviation: unit["Abbreviation"], name: unit["Name"], institution: unit["Institution"], campus: unit["Campus"])
      puts "Unit \##{result.id} created: #{result.abbreviation}, #{result.name}"
      added_count += 1
    rescue
      puts "Error on Unit create (#{unit["Abbreviation"]}, #{unit["Name"]}): #{$!}" unless type == "add"
      skipped_count += 1
    ensure
      #no op
    end
  end
  puts "#{added_count} Unit record(s) added, #{skipped_count} skipped.\n"
end

def seed_wst(type = "default")
  seed_files = {
    "Batch" => 'lib/tasks/batch_workflow_statuses.csv',
    "Bin" => 'lib/tasks/bin_workflow_statuses.csv',
    "Physical Object" => 'lib/tasks/physical_object_workflow_statuses.csv'
  }
  seed_files.each do |object_type, file|
    puts "Seeding Workflow Status Templates for object type: #{object_type}"
    wst_csv = CSV.parse(File.read(file), headers: true) 
    added_count = 0
    skipped_count = 0
    wst_csv.each do |status|
      begin
        result = WorkflowStatusTemplate.create!(name: status["Name"], description: status["Description"], sequence_index: status["Index"], object_type: object_type)
        puts "WST \##{result.id} created: #{result.name}, #{result.object_type}"
        added_count += 1
      rescue
        puts "Error on WST create (#{status["Name"]}, #{object_type}): #{$!}" unless type =="add"
        skipped_count += 1
      ensure
        #no op
      end
    end
    puts "#{added_count} WST record(s) added for object type: #{object_type}, #{skipped_count} skipped.\n"
  end
end

namespace :db do
  desc "Populate seed records into database"
    task :seed_data, [:type] => :environment do |task, args|
      type = args.type || "default"
      case type
      when "default", "add", "reseed"
        puts "Calling seed tasks with option: #{type}"
      else
        puts "Invalid type argument passed."
      end
      Rake::Task["db:unit_data"].invoke(type)
      Rake::Task["db:workflow_status_data"].invoke(type)
    end

  desc "Populate Unit records into database"
    task :unit_data, [:type] => :environment do |task, args|
      type = args.type || "default"
      if type == "reseed"
        Unit.destroy_all
        puts "Existing Unit entries destroyed."
      end
      case type
      when "default"
        if Unit.any?
          puts "Unit table already has values.  Skipping."
        else
          seed_units(type)
        end
      when "add", "reseed"
        seed_units(type)
      else
        puts "Invalid type argument: #{type}"
      end
    end

  desc "Populate Workflow Status Template records into database"
    task :workflow_status_data, [:type] => :environment do |task, args|
      type = args.type || "default"
      if type == "reseed"
        WorkflowStatusTemplate.destroy_all
        puts "Existing Workflow Status Template entries destroyed."
      end
      case type
      when "default"
        if WorkflowStatusTemplate.any?
          puts "Workflow Status Template table already has values.  Skipping."
        else
          seed_wst(type)
        end
      when "add", "reseed"
        seed_wst(type)
      else
        puts "Invalid type argument: #{type}"
      end
    end

end
