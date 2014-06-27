class Bin < ActiveRecord::Base
	
	belongs_to :batch
	belongs_to :picklist_specification
	has_many :physical_objects
	has_many :boxes
	has_many :workflow_statuses, :dependent => :destroy
	after_create :assign_default_workflow_status
	include WorkflowStatusModule
	has_many :condition_statuses, :dependent => :destroy
	accepts_nested_attributes_for :condition_statuses, allow_destroy: true
	include ConditionStatusModule

	validates :identifier, presence: true, uniqueness: true
	validates :mdpi_barcode, mdpi_barcode: true

	scope :available_bins, -> {
		where(['batch_id = 0 OR batch_id is null'])
	}

	def spreadsheet_descriptor
	  identifier
	end
end
