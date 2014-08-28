class Batch < ActiveRecord::Base
	has_many :bins
	has_many :workflow_statuses, :dependent => :destroy

	include WorkflowStatusModule
	#FIXME: resolve issue with FactoryGirl and after_initialize callbacks
	after_initialize :assign_default_workflow_status


	validates :identifier, presence: true, uniqueness: true

	def physical_objects_count
	  return bins.inject(0) { |sum, bin| sum + bin.physical_objects_count }
	end

	def media_format
	  if bins.any?
	    bin = bins.first
	    if bin.physical_objects.any?
	      bin.physical_objects.first.format
	    elsif bin.boxes.any? && bin.boxes.first.physical_objects.any?
	      bin.boxes.first.physical_objects.first.format
	    end
	  end
	end

end
