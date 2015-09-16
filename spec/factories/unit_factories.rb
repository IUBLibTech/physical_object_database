# Note that units must be manually destroyed after creation, as this table
# is NOT truncated in order to preserve seed data
FactoryGirl.define do

  factory :unit, class: Unit do
    abbreviation "B-TEST"
    name "Test Unit"
    institution "Indiana University"
    campus "Bloomington"

    trait :invalid do
      abbreviation nil
    end

  end

end
