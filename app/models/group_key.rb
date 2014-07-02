class GroupKey < ActiveRecord::Base
  has_many :physical_objects

  #FIXME: handle case of no associated objects?
  def group_identifier
    return "ERROR_NO_OBJECTS_IN_GROUP" if physical_objects.empty?
    first_object = physical_objects.order(:group_position).first
    return "ERROR_NO_OBJECT_IN_FIRST_POSITION" if first_object.nil?
    return first_object.group_identifier
  end

  def spreadsheet_descriptor
    group_identifier
  end

end
