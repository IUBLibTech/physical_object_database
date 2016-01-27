#
# requires arguments for:
# tm_object
#
shared_examples "includes year module behaviors" do |tm_object|
  let(:year_physical_object) { FactoryGirl.build :physical_object, :cdr, year: 1985 }

  describe "#year" do
    context "without a physical object set" do
      before(:each) { tm_object.physical_object = nil }
      it "returns nil" do
        expect(tm_object.year).to be_nil
      end
    end
    context "with a physical object year set" do
      before(:each) { tm_object.physical_object = year_physical_object }
      after(:each) { tm_object.physical_object = nil }
      it "returns the physical object year value" do
        expect(tm_object.year).to eq year_physical_object.year
      end
    end
  end

end

