FactoryGirl.define do
  factory :digital_provenance, class: DigitalProvenance do
    association :physical_object, factory: [:physical_object, :cdr, :barcoded]
    digitizing_entity "IU Media Digitization Studios"
    duration 42

    trait :invalid do
      physical_object_id nil
    end
  end
end
