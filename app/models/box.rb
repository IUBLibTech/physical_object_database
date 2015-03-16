class Box < ActiveRecord::Base

	belongs_to :bin
	belongs_to :spreadsheet

	has_many :physical_objects

	validates :mdpi_barcode, mdpi_barcode: true, numericality: { greater_than: 0 }
        validate :validate_bin_container
	before_save :default_values

        def packed_status?
          !self.bin.nil?
        end

	def Box.packed_status_message
          "This box has been marked full. To enable packing, uncheck the Full? status checkbox."
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

	def validate_bin_container
	  errors[:base] << "This bin (#{bin.mdpi_barcode}) contains physical objects.  You may only assign a box to a bin containing boxes." if bin && bin.physical_objects.any?
	end

end
