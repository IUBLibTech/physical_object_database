FactoryGirl.define do

  factory :user, class: User do
    name "Test User"
    username "test_username"
    web_admin true
    unit nil

    trait :invalid do
      username nil
    end

  end

end
