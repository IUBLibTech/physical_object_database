class AddPhysicalLocationToBins < ActiveRecord::Migration
  def up
    add_column :bins, :physical_location, :string
    Bin.where(physical_location: nil).update_all(physical_location: '')
  end
  def down
    remove_column :bins, :physical_location
  end
end
