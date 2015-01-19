FactoryGirl.define do

  factory :batch, class: Batch do
    identifier "Test Batch"
    destination "IU"
  end

  factory :invalid_batch, parent: :batch do
    identifier ""
  end

end
