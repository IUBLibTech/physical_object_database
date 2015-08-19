FactoryGirl.define do

  factory :processing_step, class: ProcessingStep do
    position 1
    association :signal_chain, factory: :signal_chain
    association :machine, factory: :machine

    trait :invalid do
      position 0
    end

  end

end
