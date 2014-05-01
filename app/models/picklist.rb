class Picklist < ActiveRecord::Base

	has_many :picklist_specifications
	has_many :physical_objects

	validates :name, presence: true

end
