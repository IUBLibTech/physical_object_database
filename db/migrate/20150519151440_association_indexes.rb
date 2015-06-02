class AssociationIndexes < ActiveRecord::Migration
  def up
  	add_index :bins, :batch_id
  	add_index :bins, :picklist_specification_id

  	add_index :boxes, :bin_id

  	add_index :condition_statuses, :condition_status_template_id
  	add_index :condition_statuses, :physical_object_id

  	add_index :digital_statuses, :physical_object_id

  	add_index :physical_objects, :bin_id
  	add_index :physical_objects, :box_id
  	add_index :physical_objects, :container_id

  	add_index :preservation_problems, :open_reel_tm_id 

  	add_index :technical_metadata, :physical_object_id
  	add_index :technical_metadata, :picklist_specification_id
  end

  def down
  	remove_index :bins, :batch_id
  	remove_index :bins, :picklist_specification_id

  	remove_index :boxes, :bin_id

  	remove_index :condition_statuses, :condition_status_template_id
  	remove_index :condition_statuses, :physical_object_id

  	remove_index :digital_statuses, :physical_object_id

  	remove_index :physical_objects, :bin_id
  	remove_index :physical_objects, :box_id
  	remove_index :physical_objects, :container_id

  	remove_index :preservation_problems, :open_reel_tm_id 

  	remove_index :technical_metadata, :physical_object_id
  	remove_index :technical_metadata, :picklist_specification_id
  end
end
