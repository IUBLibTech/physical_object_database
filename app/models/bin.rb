class Bin < ActiveRecord::Base
	
	belongs_to :batch
	belongs_to :picklist_specification
	has_many :physical_objects
	has_many :boxes


end
