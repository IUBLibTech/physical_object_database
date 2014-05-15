class CreateCdrTms < ActiveRecord::Migration
  def up
    create_table :cdr_tms do |t|
    	t.string :damage
    	t.boolean :fungus
    	t.boolean :other_contaminants
    	t.boolean :breakdown_of_materials
    	t.string :format_duration
      t.timestamps
    end
  end

  def down
  	drop_table :cdr_tms
  end
end
