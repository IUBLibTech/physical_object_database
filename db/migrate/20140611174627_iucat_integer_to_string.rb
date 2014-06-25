class IucatIntegerToString < ActiveRecord::Migration
  def up
  	change_column :physical_objects, :iucat_barcode, :string
  end

  def down
  	change_column :physical_objects, :iucat_barcode, :integer
  end
end
