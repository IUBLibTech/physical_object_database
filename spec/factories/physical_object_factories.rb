FactoryGirl.define do

  factory :physical_object, class: PhysicalObject do
    #required fields
    format "CD-R"
    association :unit

    #at least one must be set of MDPI barcode, IUCAT barcode, title, call number
    title "FactoryGirl object"
  end

end
