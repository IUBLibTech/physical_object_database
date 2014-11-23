class Bin < ActiveRecord::Base
        
        belongs_to :batch
        belongs_to :picklist_specification
        belongs_to :spreadsheet

        has_many :physical_objects
        has_many :boxed_physical_objects, through: :boxes, source: :physical_objects
        has_many :boxes
        has_many :workflow_statuses, :dependent => :destroy
        after_initialize :assign_default_workflow_status
	before_save :assign_inferred_workflow_status
        include WorkflowStatusModule
        extend WorkflowStatusQueryModule
        has_many :condition_statuses, :dependent => :destroy
        accepts_nested_attributes_for :condition_statuses, allow_destroy: true
        include ConditionStatusModule

        validates :identifier, presence: true, uniqueness: true
        validates :mdpi_barcode, mdpi_barcode: true
        validates :workflow_status, presence: true

        scope :available_bins, -> {
                where(['batch_id = 0 OR batch_id is null'])
        }

        def display_workflow_status
	  if self.current_workflow_status == "Batched"
	    if self.batch
              batch_status = self.batch.current_workflow_status
	    else
	      batch_status = "(No batch assigned!)"
	    end
	  end
          batch_status = "" if batch_status.in? [nil, "Created"]
          addendum = ( batch_status.blank? ? "" : " >> #{batch_status}" )
          self.current_workflow_status + addendum
        end

        def inferred_workflow_status
          if self.current_workflow_status.in? ["Created", "Sealed"] and self.batch
	    return "Batched"
          elsif self.current_workflow_status == "Batched" and !self.batch
	    return "Sealed"
	  else
	    return self.current_workflow_status
          end
        end

        def packed_status?
          self.current_workflow_status.in? ["Sealed", "Batched"]
        end

        def Bin.packed_status_message
          "This bin has been marked as sealed. To enable packing physical objects or assigning boxes, a bin must be unbatched and unsealed."
        end

        def physical_objects_count
          physical_objects.size + boxed_physical_objects.size
        end

        def spreadsheet_descriptor
          identifier
        end
end
