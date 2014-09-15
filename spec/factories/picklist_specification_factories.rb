FactoryGirl.define do

  factory :picklist_specification, class: PicklistSpecification do
    name "Test Pick List"
    description "Lorem ipsum"

    trait :cdr do
      format "CD-R"
    end
    trait :dat do
      format "DAT"
    end
    trait :lp do
      format "LP"
    end
    trait :open_reel do
      format "Open Reel Audio Tape"
    end
  end

  factory :invalid_picklist_specification, parent: :picklist_specification do
    name nil
  end

end
