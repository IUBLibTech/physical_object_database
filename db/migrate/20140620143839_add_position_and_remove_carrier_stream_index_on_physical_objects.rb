class AddPositionAndRemoveCarrierStreamIndexOnPhysicalObjects < ActiveRecord::Migration
  def up
    remove_column :physical_objects, :carrier_stream_index
    add_column :physical_objects, :group_position, :integer
  end
  def down
    add_column :physical_objects, :carrier_stream_index, :string
    remove_column :physical_objects, :group_position
  end
end
