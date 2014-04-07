class CreatePicklistSpecifications < ActiveRecord::Migration
  def change
    create_table :picklist_specifications do |t|
    	t.string :name
    	t.string :format
    	t.text :description
      t.timestamps
    end
  end
end
