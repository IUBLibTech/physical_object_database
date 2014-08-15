FactoryGirl.define do

  #specify a format type as a trait when creating a physical object
  factory :physical_object, class: PhysicalObject do
    #required fields
    association :unit

    trait :cdr do
      format "CD-R"
      after(:create) do |physical_object, evaluator|
        create(:technical_metadatum, :cdr, physical_object: physical_object)
      end
    end
    trait :dat do
      format "DAT"
    end
    trait :open_reel do
      format "Open Reel Audio Tape"
    end

    group_position 1

    #at least one must be set of MDPI barcode, IUCAT barcode, title, call number
    title "FactoryGirl object"

  end

  factory :invalid_physical_object, parent: :physical_object do
    title nil
  end
  

end
