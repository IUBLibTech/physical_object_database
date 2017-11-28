FactoryBot.define do

  factory :digital_status, class: DigitalStatus do
  	physical_object_id nil
  	physical_object_mdpi_barcode nil
  	state DigitalStatus::DIGITAL_STATUS_START
  	attention false
  	message "It has begun"
  	options nil
  	decided nil

		trait :valid do
			after(:build) do |ds, evaluator|
				if ds.physical_object.nil?
					ds.physical_object = FactoryBot.build :physical_object, :cdr, :barcoded
					ds.physical_object_mdpi_barcode = ds.physical_object.mdpi_barcode
				end
			end
		end

		trait :invalid do
			physical_object_id nil
		end
  end

end
