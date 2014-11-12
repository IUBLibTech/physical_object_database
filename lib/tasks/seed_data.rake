# seed_data.rake
# Rake tasks for seeding data
#
# Argument options:
# rake db:seed_data || rake db:seed_data[] || rake db:seed_data[default]
#   Attempts to add seed values; aborts on first error
# rake db:seed_data[add]
#   Adds new values, ignoring any errors
# rake db:seed_data[reseed]
#   Wipes existing seed values, re-adds
#
require "#{Rails.root}/lib/tasks/seed_data"

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
      Rake::Task["db:condition_status_data"].invoke(type)
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

  desc "Populate Condition Status Template records into database"
    task :condition_status_data, [:type] => :environment do |task, args|
      type = args.type || "default"
      if type == "reseed"
        ConditionStatusTemplate.destroy_all
        puts "Existing Condition Status Template entries destroyed."
      end
      case type
      when "default"
        if ConditionStatusTemplate.any?
          puts "Condition Status Template table already has values.  Skipping."
        else
          seed_cst(type)
        end
      when "add", "reseed"
        seed_cst(type)
      else
      end
    end

end
