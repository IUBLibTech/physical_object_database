class TechnicalMetadatum < ActiveRecord::Base
	actable

	belongs_to :physical_object
	belongs_to :picklist_specification

	# require a specific TM subtype
  validates :actable, presence: true

end
