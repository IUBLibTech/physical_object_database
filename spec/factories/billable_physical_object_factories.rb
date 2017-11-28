FactoryBot.define do

  factory :billable_physical_object, class: BillablePhysicalObject do
    mdpi_barcode { BarcodeHelper.valid_mdpi_barcode }
    delivery_date Time.now
  end

end
