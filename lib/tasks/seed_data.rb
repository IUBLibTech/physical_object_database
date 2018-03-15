# seed_data.rb
# Methods for seeding data; distinct from rake task
# 
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
  puts "=== Seeding Unit data ==="
  units_csv = CSV.parse(File.read('lib/tasks/units_values.csv'), headers: true)
  added_count = 0
  skipped_count = 0
  units_csv.each do |unit|
    begin
      result = Unit.create!(abbreviation: unit["Abbreviation"], name: unit["Name"], institution: unit["Institution"], campus: unit["Campus"])
      puts "\tUnit \##{result.id} created: #{result.abbreviation}, #{result.name}"
      added_count += 1
    rescue
      puts "\tError on Unit create (#{unit["Abbreviation"]}, #{unit["Name"]}): #{$!}" unless type == "add"
      skipped_count += 1
    ensure
      #no op
    end
  end
  puts "#{added_count} Unit record(s) added, #{skipped_count} skipped.\n"
end

def seed_users(type = "default")
  puts "=== Seeding User data ==="
  users_csv = CSV.parse(File.read('lib/tasks/users_values.csv'), headers: true)
  added_count = 0
  skipped_count = 0
  users_csv.each do |user|
    begin
      result = User.create!(name: user["Name"], username: user["Username"])
      puts "\tUser \##{result.id} created: #{result.name}, #{result.username}"
      added_count += 1
    rescue
      puts "\tError on User create (#{user["Name"]}, #{user["Username"]}): #{$!}" unless type == "add"
      skipped_count += 1
    ensure
      #no op
    end
  end
  puts "#{added_count} User record(s) added, #{skipped_count} skipped.\n"
end


def seed_wst(type = "default")
  puts "=== Seeding Workflow Status Template data ==="
  seed_files = {
    "Batch" => 'lib/tasks/batch_workflow_statuses.csv',
    "Bin" => 'lib/tasks/bin_workflow_statuses.csv',
    "Physical Object" => 'lib/tasks/physical_object_workflow_statuses.csv'
  }
  seed_files.each do |object_type, file|
    puts "\tObject type: #{object_type}"
    wst_csv = CSV.parse(File.read(file), headers: true) 
    added_count = 0
    skipped_count = 0
    wst_csv.each do |status|
      begin
        result = WorkflowStatusTemplate.create!(name: status["Name"], description: status["Description"], sequence_index: status["Index"], object_type: object_type)
        puts "\t\tWST \##{result.id} created: #{result.name}, #{result.object_type}"
        added_count += 1
      rescue
        puts "\t\tError on WST create (#{status["Name"]}, #{object_type}): #{$!}" unless type =="add"
        skipped_count += 1
      ensure
        #no op
      end
    end
    puts "\t#{added_count} WST record(s) added for object type: #{object_type}, #{skipped_count} skipped.\n"
  end
end

def seed_cst(type = "default")
  puts "=== Seeding Condition Status Template data ==="
  seed_files = {
    "Physical Object" => "lib/tasks/physical_object_condition_statuses.csv"
  }
  seed_files.each do |object_type, file|
    puts "\tObject type: #{object_type}"
    cst_csv = CSV.parse(File.read(file), headers: true)
    added_count = 0
    skipped_count = 0
    cst_csv.each do |status|
      begin
        result = ConditionStatusTemplate.create!(name: status["Name"], description: status["Description"], object_type: object_type, blocks_packing: status["Blocks Packing"])
        puts "\t\tCST \##{result.id} created: #{result.name}, #{result.object_type}"
        added_count += 1
      rescue
        puts "\t\tError on CST create (#{status["Name"]}, #{object_type}): #{$!}" unless type =="add"
        skipped_count += 1
      ensure
        #no op
      end
    end
    puts "\t#{added_count} CST record(s) added for object type: #{object_type}, #{skipped_count} skipped.\n"
  end
end

def seed_test_users
  if Rails.env.test?
    User::ROLES.each do |role|
      next if User.where(username: role.to_s).any?
      u = User.new(username: role.to_s, name: role.to_s)
      u.send("#{role}=", true)
      puts "Saving new user: #{role.to_s}"
      u.save
    end
  end
end
