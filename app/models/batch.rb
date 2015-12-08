class Batch < ActiveRecord::Base
	has_many :bins
	has_many :workflow_statuses, :dependent => :destroy

	include WorkflowStatusModule
	extend WorkflowStatusQueryModule
        include DestinationModule

	#FIXME: resolve issue with FactoryGirl and after_initialize callbacks
	after_initialize :assign_default_workflow_status, if: :new_record?
	before_destroy :remove_bins, prepend: true

	validates :identifier, presence: true, uniqueness: true
	validates :workflow_status, presence: true

	def physical_objects_count
	  return bins.inject(0) { |sum, bin| sum + bin.physical_objects_count }
	end

  def binned_physical_objects
    return bins.inject(PhysicalObject.none) { |collection, bin| collection += bin.contained_physical_objects }
  end

  def first_object
    bins.any? ? bins.first.first_object : nil
  end

  def digitization_start(descending = false)
    #FIXME: collapse queries?
    if self.id
      if self.bins.none?
        return nil
      elsif self.format.in? TechnicalMetadatumModule.bin_formats
  	    date = PhysicalObject.connection.execute(
  		    "SELECT physical_objects.digital_start
			    FROM bins, physical_objects
			    WHERE bins.batch_id = #{self.id} and physical_objects.bin_id = bins.id 
			    and physical_objects.digital_start is not null
			    ORDER by digital_start #{"DESC" if descending}
			    LIMIT 1"
  	    )
      else
  	    date = PhysicalObject.connection.execute(
  		    "SELECT physical_objects.digital_start
			    FROM bins, boxes, physical_objects
			    WHERE bins.batch_id = #{self.id} and boxes.bin_id = bins.id and physical_objects.box_id = boxes.id 
			    and physical_objects.digital_start is not null
			    ORDER by digital_start #{"DESC" if descending}
			    LIMIT 1"
  	    )
      end
  	  return date.size == 0 ? nil : date.first[0]
    else
      return nil
    end
  end

  def auto_accept(descending = false)
    if self.id
      ds = digitization_start(descending)
      ds.nil? ? nil : ds + TechnicalMetadatumModule.format_auto_accept_days(format).days
    else
      return nil
    end
  end

	def media_format
          format_object = self.first_object
          format_object ? format_object.format : nil
	end

	def packed_status?
	  self.current_workflow_status != "Created"
	end

	def Batch.packed_status_message
	  "This batch cannot have additional bins assigned to it.<br/>To enable bin assignment, the workflow status must be set to \"Created\".".html_safe
	end

	def remove_bins
	  self.bins.all.each do |bin|
	    bin.batch = nil
	    bin.save
	  end
	end
end
