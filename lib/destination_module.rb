# Adds destination as required attribute, and lookups for select values
#
# RSpec testing is via shared shared examples call in including models
module DestinationModule

  DESTINATION_VALUES = { "IU" => "IU", "Memnon" => "Memnon" }

  def default_destination
    self.destination ||= "Memnon"
  end

  def self.included(base)
    base.const_set(:DESTINATION_VALUES, DESTINATION_VALUES)

    base.class_eval do
      validates :destination, presence: true, inclusion: { in: DESTINATION_VALUES.keys } 
      after_initialize :default_destination

      def self.DESTINATION_VALUES
        DESTINATION_VALUES
      end
    end
  end

end
