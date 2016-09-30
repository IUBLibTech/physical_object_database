class Picklist < ActiveRecord::Base
	include DestinationModule

	has_many :physical_objects
        belongs_to :shipment

	validates :name, presence: true, uniqueness: true
	validate :completeness_validation, if: :complete

	after_save :orphan_unpacked_objects, if: :complete

	def spreadsheet_descriptor
		name
	end

	def completeness_validation
	  errors[:base] << "You may not mark this picklist \"Complete\" while there are outstanding packable items." if packable_unpacked_objects?
	end

	def all_packed?
		physical_objects.where(bin_id: [0, nil]).where(box_id: [0, nil]).empty?
	end

	def packable_unpacked_objects?
	  self.physical_objects.unpacked.each do |po|
	    return true if po.condition_statuses.blocking.none?
	  end
	  return false
	end

	def orphan_unpacked_objects
	  self.physical_objects.unpacked.each do |po|
             po.picklist = nil
             po.save!
          end
	end

end
