FactoryGirl.define do

  factory :workflow_status, class: WorkflowStatus do
    # select an existing workflow status template as these are seed data
    workflow_status_template_id { WorkflowStatusTemplate.all[rand(WorkflowStatusTemplate.all.size)].id }
    notes "Factory Girl workflow status"
  end

end
