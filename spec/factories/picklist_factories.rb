FactoryGirl.define do

  factory :picklist, class: Picklist do
    name "FactoryGirl picklist"
    description "FactoryGirl picklist description"
  end

  factory :invalid_picklist, parent: :picklist do
    name ""
    description "Invalid picklist description"
  end

end
