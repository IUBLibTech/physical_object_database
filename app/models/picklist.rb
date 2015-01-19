class Picklist < ActiveRecord::Base
	include DestinationModule

	has_many :picklist_specifications
	has_many :physical_objects

	validates :name, presence: true, uniqueness: true

	def spreadsheet_descriptor
		name
	end

end
