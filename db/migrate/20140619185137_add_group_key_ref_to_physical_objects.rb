class AddGroupKeyRefToPhysicalObjects < ActiveRecord::Migration
  def change
    add_reference :physical_objects, :group_key, index: true
  end
end
