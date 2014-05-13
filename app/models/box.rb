class Box < ActiveRecord::Base

	has_many :physical_objects
	belongs_to :bin

	validates :mdpi_barcode, mdpi_barcode: true

	def spreadsheet_descriptor
		mdpi_barcode
	end

end
