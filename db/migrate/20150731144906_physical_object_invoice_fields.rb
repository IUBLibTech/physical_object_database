class PhysicalObjectInvoiceFields < ActiveRecord::Migration
  def up
  	add_column :physical_objects, :billed, :boolean, default: false
  	add_column :physical_objects, :date_billed, :datetime
  	add_column :physical_objects, :spread_sheet_filename, :string
  	add_index :physical_objects, :spread_sheet_filename
  end

  def down
  	remove_column :physical_objects, :billed
  	remove_column :physical_objects, :date_billed
  	remove_column :physical_objects, :spread_sheet_filename
  end
end
