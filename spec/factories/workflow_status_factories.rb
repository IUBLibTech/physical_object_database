# requires a trait to assign the proper workflow template:
#   :bin, :batch, or :physical_object
FactoryBot.define do

  factory :workflow_status, class: WorkflowStatus do
    # select an existing workflow status template as these are seed data
    trait :batch do
      workflow_status_template_id { WorkflowStatusTemplate.where(object_type: "Batch")[rand(WorkflowStatusTemplate.where(object_type: "Batch").size)].id }
    end
    trait :bin do
      workflow_status_template_id { WorkflowStatusTemplate.where(object_type: "Bin")[rand(WorkflowStatusTemplate.where(object_type: "Bin").size)].id }
    end
    trait :physical_object do
      workflow_status_template_id { WorkflowStatusTemplate.where(object_type: "Physical Object")[rand(WorkflowStatusTemplate.where(object_type: "Physical Object").size)].id }
    end

    notes { 'Factory Girl workflow status' }
    user { 'test_user' }
  end

end
