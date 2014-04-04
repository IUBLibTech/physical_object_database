#This model represents the container that a carrier stream (physical object) is housed in
#in the case of a 1 to 1 relationship (one container to one carrier stream - the most common case),
#a container model will not be needed for a physical object. If a container has multople carrier streams
#(an LP jacket with 2 or more discs for instance), a container object will exist and the physical objects
#housed in that container will be associated with it
class Container < ActiveRecord::Base

	has_many :physical_objects

end
