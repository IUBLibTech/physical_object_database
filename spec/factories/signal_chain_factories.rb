FactoryBot.define do

  factory :signal_chain, class: SignalChain do
    name "FactoryBot signal chain"

    trait :invalid do
      name nil
    end

    trait :with_formats do
      transient do
        formats []
      end
      after(:build) do |signal_chain, evaluator|
        evaluator.formats.each do |format|
          SignalChainFormat.new(signal_chain: signal_chain, format: format)
        end
      end
      after(:create) do |signal_chain, evaluator|
        evaluator.formats.each do |format|
          SignalChainFormat.create(signal_chain: signal_chain, format: format)
        end
      end
    end

  end

end
