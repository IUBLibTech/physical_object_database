# Requires specifying a trait argument: :bin, or :physical_object
#
FactoryGirl.define do

  factory :condition_status, class: ConditionStatus do
    # trait filters selection of template to appropriate object type
    trait :bin do
      condition_status_template_id { ConditionStatusTemplate.where(object_type: "Bin")[rand(ConditionStatusTemplate.where(object_type: "Bin").size)].id }
    end
    trait :physical_object do
      condition_status_template_id { ConditionStatusTemplate.where(object_type: "Physical Object")[rand(ConditionStatusTemplate.where(object_type: "Physical Object").size)].id }
    end

    notes "Factory Girl condition status"
    user "test_user"
    active true
  end

end
