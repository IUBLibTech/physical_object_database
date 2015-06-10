class DigitalFile < ActiveRecord::Base
	belongs_to :physical_object
	has_many :digital_files
end
