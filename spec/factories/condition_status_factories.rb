# Requires specifying a trait argument: :bin, or :physical_object
#
FactoryBot.define do

  factory :condition_status, class: ConditionStatus do
    transient do
      blocks_packing false
    end
    # trait filters selection of template to appropriate object type
    trait :bin do
      condition_status_template_id { ConditionStatusTemplate.where(object_type: "Bin", blocks_packing: blocks_packing)[rand(ConditionStatusTemplate.where(object_type: "Bin", blocks_packing: blocks_packing).size)].id }
    end
    trait :physical_object do
      condition_status_template_id { ConditionStatusTemplate.where(object_type: "Physical Object", blocks_packing: blocks_packing)[rand(ConditionStatusTemplate.where(object_type: "Physical Object", blocks_packing: blocks_packing).size)].id }
    end

    notes "Factory Girl condition status"
    user "test_user"
    active true
  end

end
