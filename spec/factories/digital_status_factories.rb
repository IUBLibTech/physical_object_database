FactoryGirl.define do

  factory :digital_status, class: DigitalStatus do
  	physical_object_id nil
  	physical_object_mdpi_barcode nil
  	state "failed"
  	attention false
  	message "some message about the state"
  	options {{
  		accepted: "Retry processing",
			investigate: "Manually investigate data storage for what went wrong",
  		to_delete: "Discard this object and redigitze"  		
  	}}
  end

end
