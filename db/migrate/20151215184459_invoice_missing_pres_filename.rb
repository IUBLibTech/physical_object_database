class InvoiceMissingPresFilename < ActiveRecord::Migration
  def change
    remove_column :memnon_invoice_submissions, :already_billed
    remove_column :memnon_invoice_submissions, :not_found
    remove_column :memnon_invoice_submissions, :not_on_sda
    remove_column :memnon_invoice_submissions, :preservation_file_copies
    add_column :memnon_invoice_submissions, :problems_by_row, :text, limit: 4294967295
  end
end
