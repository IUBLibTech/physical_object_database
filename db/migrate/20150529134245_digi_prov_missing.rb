class DigiProvMissing < ActiveRecord::Migration

  def up
  	add_column :digital_provenances, :cleaning_comment, :text
  end
  
  def down
  	remove_column :digital_provenances, :cleaning_comment
  end

end
