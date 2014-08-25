FactoryGirl.define do

  factory :workflow_status, class: WorkflowStatus do
    association :workflow_status_template
    notes "Factory Girl workflow status"
  end

end
