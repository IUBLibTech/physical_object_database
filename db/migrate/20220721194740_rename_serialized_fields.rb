class RenameSerializedFields < ActiveRecord::Migration
  def up
    rename_column :memnon_invoice_submissions, :problems_by_row, :problems_by_row_yaml
    rename_column :memnon_invoice_submissions, :problems_by_row_json, :problems_by_row
    rename_column :digital_statuses, :options, :options_yaml
    rename_column :digital_statuses, :options_json, :options
  end
  def down
    rename_column :memnon_invoice_submissions, :problems_by_row, :problems_by_row_json
    rename_column :memnon_invoice_submissions, :problems_by_row_yaml, :problems_by_row
    rename_column :digital_statuses, :options, :options_json
    rename_column :digital_statuses, :options_yaml, :options
  end
end
