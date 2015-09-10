describe DigitalFileProvenance do
  let(:new_dfp) { DigitalFileProvenance.new }
  let(:dfp) { FactoryGirl.create :digital_file_provenance }
  let(:valid_dfp) { FactoryGirl.build :digital_file_provenance }
  let(:invalid_dfp) { FactoryGirl.build :digital_file_provenance, :invalid }
  describe "has default values" do
    specify "created_by" do
      expect(new_dfp.created_by).not_to be_blank
    end
    specify "date_digitized" do
      expect(new_dfp.date_digitized).not_to be_nil
    end
  end
  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_dfp).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_dfp).not_to be_valid
    end
  end
  describe "has required attributes:" do
    describe "filename" do
      it "must be provided" do
	valid_dfp.filename = ""
	expect(valid_dfp).not_to be_valid
      end
      it "must be unique" do
        dfp
	valid_dfp.filename = "a different filename"
	expect(valid_dfp).to be_valid
        valid_dfp.filename = dfp.filename
	expect(valid_dfp).not_to be_valid
      end
    end
  end
end
