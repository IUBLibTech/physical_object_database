require 'csv'

namespace :db do
  desc "Populate Unit records into database"
    task unit_data: :environment do
	    
	    # seed units data
    	begin
	      units_csv = CSV.parse(File.read('lib/tasks/units_values.csv'), headers: true)
	      units_csv.each do |unit|
	        Unit.create!(abbreviation: unit["Abbreviation"], name: unit["Name"])
	      end
	      puts "Database was seeded with unit data"
	    rescue
	    	puts "Error #{$!}"
	     	puts "It appears that unit data has already been seeded. Skipping to workflow statuses"
	    ensure
	   		# no op
	    end


      # seed workflow statuses
      begin
	      pos = CSV.parse(File.read('lib/tasks/physical_object_workflow_statuses.csv'), headers: true)
	      pos.each do |status|
	      	WorkflowStatusTemplate.create!(name: status["Name"], description: status["Description"], sequence_index: status["Index"], object_type: "Physical Object")
	      end
	      puts "Database has been seeded with physical object workflow statuses"

	      bins = CSV.parse(File.read('lib/tasks/bin_workflow_statuses.csv'), headers: true)
	      bins.each do |status|
	      	WorkflowStatusTemplate.create!(name: status["Name"], description: status["Description"], sequence_index: status["Index"], object_type: "Bin")
	      end
	      puts "Database has been seeded with bin workflow statuses"

	      batches = CSV.parse(File.read('lib/tasks/batch_workflow_statuses.csv'), headers: true)
	      batches.each do |status|
	      	WorkflowStatusTemplate.create!(name: status["Name"], description: status["Description"], sequence_index: status["Index"], object_type: "Batch")
	      end
	      puts "Database has been seeded with batch workflow statuses"
	     rescue
	     	puts "Error #{$!}"
	     	puts "It appears that workflow statuses have already been seeded. Omitting."
	     ensure
	   		#no op
	     end
    end
end
