FactoryBot.define do

  factory :user, class: User do
    name "Test User"
    username "test_username"
    web_admin true
    unit nil

    trait :invalid do
      username nil
    end

    trait :collection_owner do
      web_admin false
      collection_owner true
      unit_id { Unit.first&.id }
    end

  end

end
