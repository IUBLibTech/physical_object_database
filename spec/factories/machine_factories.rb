FactoryBot.define do

  factory :machine, class: Machine do
    category "FactoryBot machine"
    serial "serial"
    manufacturer "manufacturer"
    model "model"

    trait :invalid do
      category nil
      serial nil
    end

    trait :with_formats do
      transient do
        formats []
      end
      after(:build) do |machine, evaluator|
        evaluator.formats.each do |format|
          MachineFormat.new(machine: machine, format: format)
        end
      end
      after(:create) do |machine, evaluator|
        evaluator.formats.each do |format|
          MachineFormat.create(machine: machine, format: format)
        end
      end
    end

  end

end
