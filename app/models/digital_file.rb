class DigitalFile < ActiveRecord::Base
	belongs_to :physical_object
	has_one :digital_file_provenance
	accepts_nested_attributes_for :digital_file_provenance
end
