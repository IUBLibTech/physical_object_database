require 'csv'

namespace :db do
  desc "Populate Unit records into database"
    task unit_data: :environment do
      units_csv = CSV.parse(File.read('lib/tasks/units_values.csv'), headers: true)
      units_csv.each do |unit|
        Unit.create!(abbreviation: unit["Abbreviation"], name: unit["Name"])
      end
    end
end
