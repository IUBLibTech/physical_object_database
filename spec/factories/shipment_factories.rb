FactoryGirl.define do

  factory :shipment, class: Shipment do
    identifier "FactoryGirl shipment"
    description "FactoryGirl shipment"
    physical_location ""
    unit_id Unit.first.id

    trait :invalid do
      identifier nil
    end
  end

end
