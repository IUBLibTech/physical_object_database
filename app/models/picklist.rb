class Picklist < ActiveRecord::Base
	include DestinationModule

	has_many :picklist_specifications
	has_many :physical_objects

	validates :name, presence: true, uniqueness: true

	def spreadsheet_descriptor
		name
	end

	def all_packed?
		return PhysicalObject.where("picklist_id = #{id} and (bin_id is null and box_id is null)").size == 0
	end

end
