FactoryBot.define do

  factory :staging_percent, class: StagingPercentage do
    format { "CD-R" }
    memnon_percent { 10 }
    iu_percent { 10 }

    trait :invalid do
      memnon_percent { nil }
    end
  end

end
