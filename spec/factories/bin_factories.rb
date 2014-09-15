FactoryGirl.define do

  factory :bin, class: Bin do
    identifier "Test Bin"
    mdpi_barcode 0
  end

  factory :invalid_bin, parent: :bin do
    identifier nil
  end

end
