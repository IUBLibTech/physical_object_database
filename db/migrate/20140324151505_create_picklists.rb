class CreatePicklists < ActiveRecord::Migration
  def up
    create_table :picklists do |t|
    	t.string :name
    	t.string :description
      t.timestamps
    end
    add_index :picklists, :name, unique: true
  end

  def down
  	drop_table :picklists
  end
end
