describe PicklistSpecification do


  let(:picklist_specification) { FactoryBot.create :picklist_specification, :cdr }
  let(:valid_picklist_specification) { FactoryBot.build :picklist_specification, :cdr }
  let(:invalid_picklist_specification) { FactoryBot.build :invalid_picklist_specification, :cdr }

  describe "FactoryBot" do
    it "generates a valid object" do
      expect(valid_picklist_specification).to be_valid
      expect(valid_picklist_specification.technical_metadatum).to be_valid
      expect(valid_picklist_specification.technical_metadatum.specific).to be_valid
    end
    it "generates an invalid object" do
      expect(invalid_picklist_specification).not_to be_valid
    end
  end

  describe "has required fields:" do
    specify "name is required" do
      valid_picklist_specification.name = ""
      expect(valid_picklist_specification).not_to be_valid
    end
    specify "name must be unique" do
      picklist_specification
      valid_picklist_specification.name = picklist_specification.name
      expect(valid_picklist_specification).not_to be_valid
    end
    specify "format must be in formats list" do
      valid_picklist_specification.format = "invalid format"
      expect(valid_picklist_specification).not_to be_valid
    end
  end

  describe "has optional fields:" do
    specify "description is optional" do
      valid_picklist_specification.description = nil
      expect(valid_picklist_specification).to be_valid
    end
  end

  describe "has relationships:" do
    specify "has many bins" do
      expect(valid_picklist_specification.bins).to be_empty
    end
    specify "has one technical metadatum (required)" do
      expect(picklist_specification.technical_metadatum).not_to be_nil
    end
  end

  describe "has instance methods:" do
    describe "#create_tm" do
      let(:created_tm) { valid_picklist_specification.create_tm }
      it "returns a tm associated to the picklist" do
        expect(created_tm.picklist_specification).to eq valid_picklist_specification
      end
      it "returns a tm of matching format" do
        expect(created_tm.actable_type).to eq (TechnicalMetadatumModule.tm_format_classes[valid_picklist_specification.format]).to_s
      end
    end

    include_examples "ensure_tm examples" do
      let(:test_object) { picklist_specification }
    end

  end

end
