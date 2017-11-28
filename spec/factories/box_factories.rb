FactoryBot.define do

  factory :box, class: Box do
    mdpi_barcode { BarcodeHelper.valid_mdpi_barcode }
    full false
    description "FactoryBot box"
    physical_location ''

    trait :invalid do
      mdpi_barcode nil
    end
  end

  factory :invalid_box, parent: :box do
    mdpi_barcode nil
  end

end
