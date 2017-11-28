FactoryBot.define do

  factory :workflow_status_template, class: WorkflowStatusTemplate do
    name "Factory Girl workflow status template"
    description "Created by Factory Girl"
    object_type "Physical Object"
    sequence_index 100

    trait :invalid do
      name nil
    end
  end

end
