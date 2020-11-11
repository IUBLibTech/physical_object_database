FactoryBot.define do

  factory :message, class: Message do
    content { "FactoryBot message content" }

    trait :invalid do
      content { "" }
    end
  end

end
