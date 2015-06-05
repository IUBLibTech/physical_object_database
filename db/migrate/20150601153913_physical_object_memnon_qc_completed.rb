class PhysicalObjectMemnonQcCompleted < ActiveRecord::Migration
  def up
  	add_column :physical_objects, :memnon_qc_completed, :boolean
  end

  def down
  	remove_column :physical_objects, :memnon_qc_completed
  end
end
