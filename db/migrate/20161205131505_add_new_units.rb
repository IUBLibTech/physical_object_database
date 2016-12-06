class AddNewUnits < ActiveRecord::Migration
  def up
    Rake::Task['db:unit_data'].invoke('add')
  end
  def down
    puts "No action on rollback"
  end
end
