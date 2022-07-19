class MemnonInvoiceSubmission < ActiveRecord::Base
	serialize :problems_by_row
	serialize :problems_by_row_json, JSON
	validates :filename, presence: true
end
