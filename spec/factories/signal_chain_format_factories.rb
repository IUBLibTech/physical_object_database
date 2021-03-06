FactoryBot.define do

  factory :signal_chain_format, class: SignalChainFormat do
    association :signal_chain, factory: :signal_chain
    format { 'DAT' }

    trait :invalid do
      format { nil }
    end
  end

end
