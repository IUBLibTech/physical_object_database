class CreateStagingPercentages < ActiveRecord::Migration
  def up
    create_table :staging_percentages do |t|
      t.string :format, null: false
      t.integer :iu_percent, default: 10
      t.integer :memnon_percent, default: 10
      t.timestamps
    end

    AnalogSoundDiscTm::TM_FORMAT.each do |format|
      StagingPercentage.new(format: format, iu_percent: 10, memnon_percent: 10).save
    end
    CdrTm::TM_FORMAT.each do |format|
      StagingPercentage.new(format: format, iu_percent: 10, memnon_percent: 10).save
    end
    DatTm::TM_FORMAT.each do |format|
      StagingPercentage.new(format: format, iu_percent: 10, memnon_percent: 10).save
    end
    OpenReelTm::TM_FORMAT.each do |format|
      StagingPercentage.new(format: format, iu_percent: 10, memnon_percent: 10).save
    end
    BetacamTm::TM_FORMAT.each do |format|
      StagingPercentage.new(format: format, iu_percent: 10, memnon_percent: 10).save
    end
    EightMillimeterVideoTm::TM_FORMAT.each do |format|
      StagingPercentage.new(format: format, iu_percent: 10, memnon_percent: 10).save
    end
    UmaticVideoTm::TM_FORMAT.each do |format|
      StagingPercentage.new(format: format, iu_percent: 10, memnon_percent: 10).save
    end
  end

  def down
    drop_table :staging_percentages
  end
end
