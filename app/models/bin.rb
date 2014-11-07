class Bin < ActiveRecord::Base
	
	belongs_to :batch
	belongs_to :picklist_specification
	belongs_to :spreadsheet

	has_many :physical_objects
	has_many :boxed_physical_objects, through: :boxes, source: :physical_objects
	has_many :boxes
	has_many :workflow_statuses, :dependent => :destroy
	after_initialize :assign_default_workflow_status
	include WorkflowStatusModule
	has_many :condition_statuses, :dependent => :destroy
	accepts_nested_attributes_for :condition_statuses, allow_destroy: true
	include ConditionStatusModule

	validates :identifier, presence: true, uniqueness: true
	validates :mdpi_barcode, mdpi_barcode: true
	validates :workflow_status, presence: true

	scope :available_bins, -> {
		where(['batch_id = 0 OR batch_id is null'])
	}

        def packed_status?
          ["Sealed", "Batched"].include? self.current_workflow_status
        end

	def Bin.packed_status_message
	  "This bin has been marked as sealed. To enable packing physical objects and assigning boxes, unseal the bin."
	end

	def physical_objects_count
	  physical_objects.size + boxed_physical_objects.size
	end

	def spreadsheet_descriptor
	  identifier
	end
end
