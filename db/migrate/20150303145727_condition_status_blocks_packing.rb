class ConditionStatusBlocksPacking < ActiveRecord::Migration
  
  def up
		add_column :condition_status_templates, :blocks_packing, :boolean, default: false 
		ConditionStatusTemplate.update_all(blocks_packing: true)  	
  	ConditionStatusTemplate.where(name:  ['Catalog Problem','Send To IU']).each do |cst|
  		cst.update(blocks_packing: false)
  	end
  end
  
  def down
  	remove_column :condition_status_templates, :blocks_packing
  end

end
