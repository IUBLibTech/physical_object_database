class AddPackingIndexToPhysicalObjects < ActiveRecord::Migration
  def change
    add_index "physical_objects", ["picklist_id", "group_key_id", "group_position", "id"], name: "index_physical_objects_on_packing_sort", using: :btree
  end
end
