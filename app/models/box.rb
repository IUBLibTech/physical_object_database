class Box < ActiveRecord::Base

	belongs_to :bin
	belongs_to :spreadsheet

	has_many :physical_objects

	validates :mdpi_barcode, mdpi_barcode: true, numericality: { greater_than: 0 }
	before_save :default_values

        def packed_status?
          !self.bin.nil?
        end

	def Box.packed_status_message
          "This box has been associated to a bin. To enable packing, remove it from the bin."
        end

	def spreadsheet_descriptor
		mdpi_barcode
	end

	def physical_objects_count
		physical_objects.size
	end

	def default_values
	  self.full ||= false
	  self.description ||= ""
	end

end
