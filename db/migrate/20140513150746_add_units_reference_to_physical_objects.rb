class AddUnitsReferenceToPhysicalObjects < ActiveRecord::Migration
  def up
    #add new column
    add_column :physical_objects, :unit_id, :integer
    add_index :physical_objects, :unit_id

    #set values
    #If we are migration clean abbreviation/name values, those go here

    #remove old column
    remove_column :physical_objects, :unit
  end

  def down
    #add old column
    add_column :physical_objects, :unit, :string

    #set values
    #If we are migration clean abbreviation/name values, those go here

    #remove new column
    remove_column :physical_objects, :unit_id
  end
end
