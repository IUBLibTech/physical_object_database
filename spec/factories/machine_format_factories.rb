FactoryBot.define do

  factory :machine_format, class: MachineFormat do
    association :machine, factory: :machine
    format "CD-R"

    trait :invalid do
      format nil
    end
  end

end
