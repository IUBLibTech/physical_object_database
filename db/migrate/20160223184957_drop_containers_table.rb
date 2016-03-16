class DropContainersTable < ActiveRecord::Migration
  def up
    drop_table :containers
  end
  def down
    create_table :containers do |t|
      t.timestamps
    end
  end
end
