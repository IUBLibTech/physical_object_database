describe DigitalProvenance, type: :model do
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

  describe "has optional attributes:" do
    [:digitizing_entity, :date, :comments, :cleaning_date, :baking, :cleaning_comment, :xml, :duration, :batch_processing_flag].each do |att|
      specify att do
        valid_dp.send("#{att}=",nil)
        expect(valid_dp).to be_valid
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
    context "when all required fields are present" do
      it "returns true" do
        expect(valid_dp.complete?).to eq true
      end
    end
    context "when any required fields are missing" do
      before(:each) { valid_dp.duration = nil }
      it "returns false" do
        expect(valid_dp.complete?).to eq false
      end
    end
    
  end

  describe "#digitizing_entity_values" do
    it "returns the class constant" do
      expect(valid_dp.digitizing_entity_values).to eq DigitalProvenance::DIGITIZING_ENTITY_VALUES
    end
  end

end
