FactoryGirl.define do

  factory :condition_status_template, class: ConditionStatusTemplate do
    name "Factory Girl condition status template"
    description "Created by Factory Girl"
    object_type "Physical Object"

    trait :invalid do
      name nil
    end
  end

end
