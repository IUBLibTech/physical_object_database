class UpdateStagingPercentageForFilm < ActiveRecord::Migration
  def up
    puts "Run StagingPercentagesController.validate_formats"
    StagingPercentagesController.validate_formats
    film_percentages = StagingPercentage.where(format: 'Film').first
    if film_percentages
      puts "Updating Film percentages to 100%"
      film_percentages.iu_percent = 100
      film_percentages.memnon_percent = 100
      film_percentages.save!
    end
  end
  def down
    puts "No action on rollback"
  end
end
