class MemnonInvoiceSubmission < ActiveRecord::Base

	serialize :already_billed
	serialize :not_found
	serialize :not_on_sda
	serialize :preservation_file_copies
	serialize :problems_by_row

end
