class Box < ActiveRecord::Base

	has_many :physical_objects
	belongs_to :bin

	validates :mdpi_barcode, mdpi_barcode: true

end
