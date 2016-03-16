class MemnonInvoiceSubmission < ActiveRecord::Base
	serialize :problems_by_row
	validates :filename, presence: true
end
