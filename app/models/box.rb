class Box < ActiveRecord::Base

	belongs_to :bin
	belongs_to :spreadsheet

	has_many :physical_objects

	validates :mdpi_barcode, mdpi_barcode: true, numericality: { greater_than: 0 }
  validate :validate_bin_container
	before_save :default_values
	after_save :set_container_format
	before_destroy :remove_physical_objects, prepend: true

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

  def set_container_format
    if format && bin && bin.format.nil?
      bin.format = format; bin.save
    end
  end

	def validate_bin_container
	  if bin
	    if bin.physical_objects.any?
	      errors[:base] << Bin.invalid_box_assignment_message
      elsif !format.blank? && !bin.format.blank? && bin.format != format
        errors[:base] << "This bin (#{bin.mdpi_barcode}) contains boxes of a different format (#{bin.format}).  You may only assign a box to a bin containing the matching format (#{format})."
      end
    end
	end

  def remove_physical_objects
    self.physical_objects.each do |po|
      po.box = nil
      po.save
    end
  end

  def media_format
    if physical_objects.any?
      physical_objects.first.format
    else
      nil
    end
  end

end
