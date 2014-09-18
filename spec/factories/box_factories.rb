FactoryGirl.define do

  factory :box, class: Box do
    mdpi_barcode 0
  end

  factory :invalid_box, parent: :box do
    mdpi_barcode nil
  end

end
