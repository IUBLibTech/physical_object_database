class CreateGroupKeys < ActiveRecord::Migration
  def change
    create_table :group_keys do |t|
      t.string :identifier

      t.timestamps
    end
  end
end
