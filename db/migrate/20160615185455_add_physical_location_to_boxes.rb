class AddPhysicalLocationToBoxes < ActiveRecord::Migration
  def change
    add_column :boxes, :physical_location, :string
  end
end
