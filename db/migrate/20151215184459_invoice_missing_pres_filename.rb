class InvoiceMissingPresFilename < ActiveRecord::Migration
  def change
    remove_column :memnon_invoice_submissions, :already_billed, :text, limit: 4294967295
    remove_column :memnon_invoice_submissions, :not_found, :text, limit: 4294967295
    remove_column :memnon_invoice_submissions, :not_on_sda, :text, limit: 4294967295
    remove_column :memnon_invoice_submissions, :preservation_file_copies, :text, limit: 4294967295
    add_column :memnon_invoice_submissions, :problems_by_row, :text, limit: 4294967295
  end
end
