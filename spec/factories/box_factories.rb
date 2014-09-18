FactoryGirl.define do

  factory :box, class: Box do
    mdpi_barcode { BarcodeHelper.valid_mdpi_barcode }
  end

  factory :invalid_box, parent: :box do
    mdpi_barcode nil
  end

end
