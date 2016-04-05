class CreateMemnonInvoiceSubmission < ActiveRecord::Migration
  def change
  	create_table :memnon_invoice_submissions do |t|
  		t.string :filename
  		t.datetime :submission_date
  		t.boolean :successful_validation
  		t.text :error_message,:limit => 4294967295
  		t.integer :validation_completion_percent
  	end
  end
end
