describe Shipment do
  let(:shipment) { FactoryGirl.create :shipment }
  let(:valid_shipment) { FactoryGirl.build :shipment }
  let(:invalid_shipment) { FactoryGirl.build :shipment, :invalid }

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_shipment).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_shipment).not_to be_valid
    end
  end
  describe "has required attributes" do
    describe "identifier" do
      it "must be present" do
        valid_shipment.identifier = nil
        expect(valid_shipment).not_to be_valid
      end
      it "must be unique" do
        valid_shipment.identifier = shipment.identifier
        expect(valid_shipment).not_to be_valid
      end
    end
  end
  describe "has optional attributes" do
    ["description", "physical_location"].each do |att|
      specify att do
        valid_shipment.send("#{att}=", nil)
        expect(valid_shipment).to be_valid
      end
    end
  end
  describe "has relationships" do
    describe "unit" do
      it "is required" do
        valid_shipment.unit = nil
        expect(valid_shipment).not_to be_valid
      end
    end
    specify "physical_objects" do
      expect(valid_shipment).to respond_to :physical_objects
    end
    specify "picklists" do
      expect(valid_shipment).to respond_to :picklists
    end
  end
  describe "#picklist_for_format" do
    let(:format) { 'CD-R' }
    context "with an existing picklist" do
      let(:existing) { shipment.picklists.create(name: 'Prepopulated', format: format) }
      it "returns the existing picklist" do
        existing
        expect(shipment.picklist_for_format(format)).to eq existing
      end
    end
    context "without an existing picklist" do
      it "creates a new picklist" do
        expect { shipment.picklist_for_format(format) }.to change(Picklist, :count).by(1)
      end
      it "returns the picklist" do
        picklist = shipment.picklist_for_format(format)
        expect(picklist).to be_a Picklist
        expect(picklist.shipment).to eq shipment
        expect(picklist.format).to eq format
      end
    end
  end
end
