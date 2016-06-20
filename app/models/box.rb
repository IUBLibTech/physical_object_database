class Box < ActiveRecord::Base

	belongs_to :bin
	belongs_to :spreadsheet

	has_many :physical_objects

	validates :mdpi_barcode, mdpi_barcode: true, numericality: { greater_than: 0 }
  validates :physical_location, inclusion: { in: Bin::PHYSICAL_LOCATION_VALUES }
  before_validation :set_format_from_container
  validate :validate_bin_container
	after_initialize :default_values
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
	  self.description ||= ''
	  self.physical_location ||= ''
	end

  def set_container_format
    if !format.blank? && bin && bin.format.blank?
      bin.format = format; bin.save
    end
  end

  def set_format_from_container
    if format.blank?  && bin && !bin.format.blank?
      self.format = bin.format
    end
  end

	def validate_bin_container
	  if bin
	    if bin.physical_objects.any?
	      errors[:base] << Bin.invalid_box_assignment_message
      elsif !bin.format.blank?
        if format.blank?
          errors[:base] << "This box (#{mdpi_barcode}) must have a format set before it can be assigned to a format-specific bin."
        elsif bin.format != format
          errors[:base] << "This bin (#{bin.mdpi_barcode}) contains boxes of a different format (#{bin.format}).  You may only assign a box to a bin containing the matching format (#{format})."
        end
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
