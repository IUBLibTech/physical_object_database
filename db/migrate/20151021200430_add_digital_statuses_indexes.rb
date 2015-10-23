class AddDigitalStatusesIndexes < ActiveRecord::Migration
  def change
    add_index :digital_statuses, [:created_at, :state, :physical_object_id], name: 'quality_control_staging'
    add_index :digital_provenances, :physical_object_id
  end
end
