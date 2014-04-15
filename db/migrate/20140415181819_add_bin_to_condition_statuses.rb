class AddBinToConditionStatuses < ActiveRecord::Migration
  def change
    add_column :condition_statuses, :bin_id, :integer
    add_index :condition_statuses, [:bin_id, :condition_status_template_id], name: :index_cs_on_bin_and_cst
  end
end
