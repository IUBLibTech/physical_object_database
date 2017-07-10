class AddFilmToPhysicalObjects < ActiveRecord::Migration
  def change
    add_column :physical_objects, :film, :boolean
  end
end
