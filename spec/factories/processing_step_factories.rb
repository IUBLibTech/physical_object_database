FactoryBot.define do

  factory :processing_step, class: ProcessingStep do
    position 1
    association :signal_chain, factory: :signal_chain
    association :machine, factory: :machine

    trait :invalid do
      position 0
    end

    trait :with_formats do
      transient do
        formats []
      end
      after(:build) do |ps, evaluator|
        evaluator.formats.each do |format|
          ps.signal_chain.signal_chain_formats.new(format: format)
          ps.machine.machine_formats.new(format: format)
        end
      end
      after(:create) do |ps, evaluator|
        evaluator.formats.each do |format|
          ps.signal_chain.signal_chain_formats.create(format: format)
          ps.machine.machine_formats.create(format: format)
        end
      end
    end
  end

end
