class ChangeStagingPercentagesForCylinder < ActiveRecord::Migration
  def up
    sp = StagingPercentage.where(format: "Cylinder").first
    if sp
      sp.iu_percent = 100
      sp.save!
    end
  end
  def down
    sp = StagingPercentage.where(format: "Cylinder").first
    if sp
      sp.iu_percent = 10
      sp.save!
    end
  end
end
