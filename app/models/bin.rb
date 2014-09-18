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

	scope :available_bins, -> {
		where(['batch_id = 0 OR batch_id is null'])
	}

        def packed_status?
          ["Packed"].include? self.current_workflow_status.name
        end

	def Bin.packed_status_message
	  "This bin has been marked as packed. To enable packing and assigning boxes, please change the workflow status."
	end

	def physical_objects_count
	  physical_objects.size + boxed_physical_objects.size
	end

	def spreadsheet_descriptor
	  identifier
	end
end
