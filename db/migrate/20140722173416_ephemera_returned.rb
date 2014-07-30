class EphemeraReturned < ActiveRecord::Migration
  
  def up
  	add_column :physical_objects, :ephemera_returned, :boolean
  end

  def down
  	remove_column :physical_objects, :ephemera_returned, :boolean
  end

end
