class AddNewRejectedByMemnonConditionStatus < ActiveRecord::Migration
  def up
    Rake::Task['db:seed_data'].invoke('add')
  end
  def down
    ConditionStatusTemplate.where(name: 'Rejected by Memnon').destroy_all
  end
end
