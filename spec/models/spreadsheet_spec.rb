describe Spreadsheet do
  let(:spreadsheet) { FactoryGirl.create :spreadsheet }
  let(:valid_spreadsheet) { FactoryGirl.build :spreadsheet }
  let(:box) { FactoryGirl.create :box, spreadsheet: spreadsheet }
  let(:bin) { FactoryGirl.create :bin, spreadsheet: spreadsheet }
  let(:batch) { FactoryGirl.create :batch, spreadsheet: spreadsheet }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, spreadsheet: spreadsheet }

  it "gets a valid object from FactoryGirl" do
    expect(valid_spreadsheet).to be_valid
  end

  describe "has required fields: " do
    it "filename is required" do
      valid_spreadsheet.filename = ""
      expect(valid_spreadsheet).not_to be_valid
    end
    it "filename must be unique" do
      valid_spreadsheet.filename = spreadsheet.filename
      expect(valid_spreadsheet).not_to be_valid
    end
  end

  describe "has optional fields: " do
    it "note is optional" do
      valid_spreadsheet.note = nil
      expect(valid_spreadsheet).to be_valid
    end
  end

  describe "relationships:" do
    it "has many batches" do
      expect(valid_spreadsheet.batches.size).to eq 0
    end
    specify "batches are NOT deleted upon spreadsheet deletion" do
      batch_id = batch.id
      spreadsheet.destroy
      expect(Batch.where(id: batch_id)).not_to be_empty
    end
    it "has many bins" do
      expect(valid_spreadsheet.bins.size).to eq 0
    end
    specify "bins are NOT deleted upon spreadsheet deletion" do
      bin_id = bin.id
      spreadsheet.destroy
      expect(Bin.where(id: bin_id)).not_to be_empty
    end
    it "has many boxes" do
      expect(valid_spreadsheet.boxes.size).to eq 0
    end
    specify "boxes are NOT deleted upon spreadsheet deletion" do
      box_id = box.id
      spreadsheet.destroy
      expect(Box.where(id: box_id)).not_to be_empty
    end
    it "has many physical objects" do
      expect(valid_spreadsheet.physical_objects.size).to eq 0
    end
    specify "physical objects are deleted upon spreadsheet deletion" do
      physical_object_id = physical_object.id
      spreadsheet.destroy
      expect(PhysicalObject.where(id: physical_object_id)).to be_empty
    end
  end

  describe "virtual methods" do
    describe "#spreadsheet_descriptor" do
      it "returns filename" do
        expect(valid_spreadsheet.filename).to eq valid_spreadsheet.spreadsheet_descriptor
      end
    end
  end

end
