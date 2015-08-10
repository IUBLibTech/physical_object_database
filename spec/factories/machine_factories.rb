FactoryGirl.define do

  factory :machine, class: Machine do
    category "FactoryGirl machine"
    serial "serial"
    manufacturer "manufacturer"
    model "model"
  end

  trait :invalid do
    category nil
    serial nil
  end

end
