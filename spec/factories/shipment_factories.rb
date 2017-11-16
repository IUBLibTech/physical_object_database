FactoryBot.define do

  factory :shipment, class: Shipment do
    identifier "FactoryBot shipment"
    description "FactoryBot shipment"
    physical_location ""
    unit_id Unit.first.id

    trait :invalid do
      identifier nil
    end
  end

end
