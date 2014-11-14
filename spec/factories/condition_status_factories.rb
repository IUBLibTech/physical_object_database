FactoryGirl.define do

  factory :condition_status, class: ConditionStatus do
    # select an existing workflow status template as these are seed data
    condition_status_template_id { ConditionStatusTemplate.all[rand(ConditionStatusTemplate.all.size)].id }
    notes "Factory Girl condition status"
    user "test_user"
    active true
  end

end
