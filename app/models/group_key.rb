class GroupKey < ActiveRecord::Base
  has_many :physical_objects

  #FIXME: handle case of no associated objects?
  def group_identifier
    return physical_objects.find_by(group_position: 1).group_identifier unless physical_objects.empty?
    return "ERROR_NO_OBJECTS_IN_GROUP"
  end

end
