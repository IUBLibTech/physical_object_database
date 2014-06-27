class AddMetadataToPhysicalObject < ActiveRecord::Migration
  def up
  	add_column :physical_objects, :author, :string
  	add_column :physical_objects, :catalog_key, :string
  	add_column :physical_objects, :collection_name, :string
  	add_column :physical_objects, :generation, :string
  	add_column :physical_objects, :oclc_number, :string
  	add_column :physical_objects, :other_copies, :boolean
  	add_column :physical_objects, :year, :string

 		remove_column :physical_objects, :shelf_location
  	remove_column :physical_objects, :content_duration
  end

  def down
  	add_column :physical_objects, :content_duration, :string
 		add_column :physical_objects, :shelf_location, :string
  	
  	remove_column :physical_objects, :year, :string
  	remove_column :physical_objects, :other_copies, :boolean
  	remove_column :physical_objects, :oclc_number, :string
  	remove_column :physical_objects, :generation, :string
  	remove_column :physical_objects, :collection_name, :string
  	remove_column :physical_objects, :catalog_key, :string
  	remove_column :physical_objects, :author, :string
  end

end
