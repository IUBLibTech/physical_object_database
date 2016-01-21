describe DigitalProvenance, type: :model do
  #let!(:physical_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }
  #let(:dp) { physical_object.digital_provenance }
  let(:dp) { FactoryGirl.create :digital_provenance }
  let(:valid_dp) { FactoryGirl.build :digital_provenance }
  let(:invalid_dp) { FactoryGirl.build :digital_provenance, :invalid }

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_dp).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_dp).not_to be_valid
    end
  end

  skip "has required attributes:" do
    describe "duration" do
      it "must be present" do
        valid_dp.duration = nil
	expect(valid_dp).not_to be_valid
      end
    end
    describe "digitizing entity" do
      it "must be present" do
        valid_dp.digitizing_entity = nil
	expect(valid_dp).not_to be_valid
      end
      it "must be in valid inclusion list" do
        valid_dp.digitizing_entity = "Invalid value"
	expect(valid_dp).not_to be_valid
      end
    end
  end

  describe "has relationships:" do
    describe "physical_object" do
      it "belongs to" do
        expect(valid_dp).to respond_to :physical_object_id
      end
      it "requires" do
        valid_dp.physical_object = nil
	expect(valid_dp).not_to be_valid
      end
    end
  end

  describe "#complete?" do
    it "returns a Boolean" do
      expect(valie_dfp.complete?).to be_in [true, false]
    end
  end

end
