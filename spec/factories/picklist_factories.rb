FactoryBot.define do

  factory :picklist, class: Picklist do
    name "FactoryBot picklist"
    description "FactoryBot picklist description"
    destination "Memnon"
    complete false
    format nil
    shipment nil

    trait :invalid do
      name ""
      description "Invalid picklist description"
    end
  end

  factory :invalid_picklist, parent: :picklist do
    name ""
    description "Invalid picklist description"
  end

end
