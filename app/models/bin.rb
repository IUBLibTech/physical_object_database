class Bin < ActiveRecord::Base
  require 'net/http'

	default_scope { order(:identifier) }
	after_initialize :default_values
        
        belongs_to :batch
        belongs_to :picklist_specification
        belongs_to :spreadsheet

        has_many :physical_objects
        has_many :boxed_physical_objects, through: :boxes, source: :physical_objects
        has_many :boxes
        has_many :workflow_statuses, :dependent => :destroy
        after_initialize :assign_default_workflow_status
        validate :validate_batch_container
	before_save :assign_inferred_workflow_status
	before_destroy :remove_physical_objects, prepend: true
	after_save :set_container_format
        include WorkflowStatusModule
        has_many :condition_statuses, :dependent => :destroy
        accepts_nested_attributes_for :condition_statuses, allow_destroy: true
        include ConditionStatusModule
        include DestinationModule

        validates :identifier, presence: true, uniqueness: true
        validates :mdpi_barcode, mdpi_barcode: true, uniqueness: true, numericality: { greater_than: 0 }
        validates :workflow_status, presence: true
	PHYSICAL_LOCATION_VALUES = ['', 'ALF', 'ML', 'ATM', 'IC', 'At Unit']
        validates :physical_location, inclusion: { in: PHYSICAL_LOCATION_VALUES }

        scope :available_bins, -> {
                where(batch_id: [0, nil])
        }

	def default_values
		self.physical_location ||= ''
	end

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
          self.current_workflow_status.to_s + addendum
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

        def Bin.invalid_box_assignment_message
          "This bin contains physical objects.  You may only assign a box to a bin containing boxes."
        end

        def physical_objects_count
          physical_objects.size + boxed_physical_objects.size
        end

        def spreadsheet_descriptor
          identifier
        end

  def contained_physical_objects
    return self.physical_objects if self.physical_objects.any?
    self.boxed_physical_objects
  end

  def first_object
    self.contained_physical_objects.first
  end

  def media_format
    format_object = first_object
    format_object ? format_object.format : nil
  end

  def set_container_format
   if !format.blank? && batch && batch.format.blank?
     batch.format = format; batch.save
   end
  end

  def validate_batch_container
    if batch && !batch.format.blank?
      if format.blank?
        errors[:base] << "This bin must have a format value set, before it can be assigned to a batch."
      elsif batch.format != format
        errors[:base] << "This batch (#{batch.identifier}) contains bins of a different format (#{batch.format}).  You may only assign a bin to a batch containing the matching format (#{format})."
      end
    end
  end

  def remove_physical_objects
    self.physical_objects.each do |po|
      po.bin = nil
      po.save
    end
  end

  def post_to_filmdb
    return unless self.format == 'Film'
    uri = URI.parse(Pod.config[:filmdb_update_url].to_s + self.mdpi_barcode.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request.basic_auth(Settings.filmdb_user, Settings.filmdb_pass)
    result = http.request(request)
    result
  end

  # Updates "Not started" physical objects to "Rejected" (by Memnon)
  def reject_physical_objects
    self.physical_objects.where(digital_workflow_category: 'not_started').each do |po|
      po.update_attribute(:digital_workflow_category, 'rejected')
    end
    self.boxes.each { |box| box.reject_physical_objects }
  end
end
