class AddSerializedFields < ActiveRecord::Migration
  def up
    add_column :memnon_invoice_submissions, :problems_by_row_json, :text, limit: 4294967295
    add_column :digital_statuses, :options_json, :text, limit: 65535
  end
  def down
    remove_column :memnon_invoice_submissions, :problems_by_row_json
    remove_column :digital_statuses, :options_json
  end
end
