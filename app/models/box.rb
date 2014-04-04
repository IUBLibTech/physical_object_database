class Box < ActiveRecord::Base

has_many :physical_objects
belongs_to :bin

end
