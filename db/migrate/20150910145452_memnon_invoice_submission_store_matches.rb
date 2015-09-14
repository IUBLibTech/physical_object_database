class MemnonInvoiceSubmissionStoreMatches < ActiveRecord::Migration
  def up
  	remove_column :memnon_invoice_submissions, :error_message
  	add_column :memnon_invoice_submissions, :already_billed, :text, limit: 4294967295
  	add_column :memnon_invoice_submissions, :not_found, :text, limit: 4294967295
  	add_column :memnon_invoice_submissions, :not_on_sda, :text, limit: 4294967295
  	add_column :memnon_invoice_submissions, :preservation_file_copies, :text, limit: 4294967295
  	add_column :memnon_invoice_submissions, :bad_headers, :boolean, default: false
    add_column :memnon_invoice_submissions, :other_error, :text, limit: 4294967295

  end

  def down
  	add_column :memnon_invoice_submissions, :error_message, :text, limit: 4294967295
  	remove_column :memnon_invoice_submissions, :already_billed
  	remove_column :memnon_invoice_submissions, :not_on_sda
  	remove_column :memnon_invoice_submissions, :not_found
  	remove_column :memnon_invoice_submissions, :preservation_file_copies
  	remove_column :memnon_invoice_submissions, :bad_headers
    remove_column :memnon_invoice_submissions, :other_error
  end
end
