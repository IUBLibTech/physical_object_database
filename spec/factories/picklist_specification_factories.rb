FactoryBot.define do

  factory :picklist_specification, class: PicklistSpecification do
    name { "Test Pick List" }
    description { "Lorem ipsum" }

    trait :cdr do
      format { "CD-R" }
      association :technical_metadatum, factory: [:technical_metadatum, :cdr]
    end
    trait :dat do
      format { "DAT" }
      association :technical_metadatum, factory: [:technical_metadatum, :dat]
    end
    trait :lp do
      format { "LP" }
      association :technical_metadatum, factory: [:technical_metadatum, :lp]
    end
    trait :open_reel do
      format { "Open Reel Audio Tape" }
      association :technical_metadatum, factory: [:technical_metadatum, :open_reel]
    end
  end

  factory :invalid_picklist_specification, parent: :picklist_specification do
    name { nil }
  end

end
