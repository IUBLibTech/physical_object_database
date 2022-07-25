class MemnonInvoiceSubmission < ActiveRecord::Base
	serialize :problems_by_row, JSON
	validates :filename, presence: true
end
