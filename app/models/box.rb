class Box < ActiveRecord::Base

	belongs_to :bin
	belongs_to :spreadsheet

	has_many :physical_objects

	validates :mdpi_barcode, mdpi_barcode: true

	def spreadsheet_descriptor
		mdpi_barcode
	end

	def physical_objects_count
		physical_objects.size
	end

end
