FactoryGirl.define do

  factory :digital_status, class: DigitalStatus do
  	physical_object_id nil
  	physical_object_mdpi_barcode nil
  	state DigitalStatus::DIGITAL_STATUS_START
  	attention false
  	message "It has begun"
  	options nil
  end

end
