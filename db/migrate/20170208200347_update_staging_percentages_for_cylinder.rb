class UpdateStagingPercentagesForCylinder < ActiveRecord::Migration
  def up
    puts "Run StagingPercentagesController.validate_formats"
    StagingPercentagesController.validate_formats
  end
  def down
    puts "No action on rollback"
  end
end
