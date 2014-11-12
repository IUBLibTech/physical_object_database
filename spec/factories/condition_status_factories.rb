FactoryGirl.define do

  factory :condition_status, class: ConditionStatus do
    association :condition_status_template
    notes "Factory Girl condition status"
    user "test_user"
    active true
  end

end
