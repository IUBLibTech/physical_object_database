FactoryGirl.define do

  factory :message, class: Message do
    content "FactoryGirl message content"

    trait :invalid do
      content ""
    end
  end

end
