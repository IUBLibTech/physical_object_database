FactoryGirl.define do

  factory :signal_chain, class: SignalChain do
    name "FactoryGirl signal chain"

    trait :invalid do
      name nil
    end
  end

end
