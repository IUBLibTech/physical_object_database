class RenameEphemira < ActiveRecord::Migration
  def up
  	rename_column :physical_objects, :has_ephemira, :has_ephemera
  end

  def down
  	rename_column :physical_objects, :has_ephemera, :has_ephemira
  end
end
