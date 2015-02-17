class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
      t.string :username

      t.timestamps
    end
    Rake::Task['db:seed_data'].invoke('add')
  end
  def down
    drop_table :users
  end
end
