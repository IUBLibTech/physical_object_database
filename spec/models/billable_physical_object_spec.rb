describe BillablePhysicalObject do
  let(:valid_bpo) { FactoryGirl.build :billable_physical_object }
  describe "FactoryGirl" do
    it "returns a valid object" do
    end
  end
  describe "has optional fields:" do
    specify "mdpi_barcode" do
      valid_bpo.mdpi_barcode = nil
      expect(valid_bpo).to be_valid
    end
    specify "delivery_date" do
      valid_bpo.delivery_date = nil
      expect(valid_bpo).to be_valid
    end
  end
end
