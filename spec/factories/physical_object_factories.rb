FactoryGirl.define do

  #specify a format type as a trait when creating a physical object
  factory :physical_object, class: PhysicalObject do
    #required fields
    association :unit

    trait :cdr do
      format "CD-R"
    end
    trait :dat do
      format "DAT"
    end
    trait :open_reel do
      format "Open Reel Audio Tape"
    end

    #at least one must be set of MDPI barcode, IUCAT barcode, title, call number
    title "FactoryGirl object"
  end

end
