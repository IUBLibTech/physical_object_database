class CreateDigitalFiles < ActiveRecord::Migration
  def up
    create_table :digital_files do |t|
    	t.integer :physical_object_id, limit: 8
    	t.string :filename
      #preservation master, production master, etc
      t.string :role
    	t.string :format
    	t.text :description
      t.timestamps
    end
  end

  def down
  	drop_table :digital_files
  end
end
