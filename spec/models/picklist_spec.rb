describe Picklist do

  let(:picklist) { FactoryGirl.create :picklist }
  let(:valid_picklist) { FactoryGirl.build :picklist }
  let(:invalid_picklist) { FactoryGirl.build :picklist, :invalid }
  let(:physical_object) { FactoryGirl.create :physical_object, :boxable, picklist: picklist }
  let(:blocking_condition) { FactoryGirl.create :condition_status, :physical_object, active: true, blocks_packing: true, physical_object: physical_object }
  let(:box) { FactoryGirl.create :box }

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_picklist).to be_valid
    end
    it "provides an invalid object with :invalid trait" do
      expect(invalid_picklist).not_to be_valid
    end
  end

  describe "has attributes:" do
    it "requires a name" do
      expect(picklist.name).not_to be_blank
      picklist.name = ""
      expect(picklist).to be_invalid
    end
    it "requires a unique name" do
      expect(valid_picklist).to be_valid
      picklist
      expect(valid_picklist).to be_invalid
    end
    it "allows a description" do
      expect(picklist.description).not_to be_blank
      picklist.description = ""
      expect(picklist).to be_valid
    end
    it "allows a format" do
      valid_picklist.format = nil
      expect(valid_picklist).to be_valid
    end

    # destination handled by shared examples
    include_examples "includes DestinationModule", FactoryGirl.build(:picklist)

    describe "complete indicator:" do
      before(:each) { picklist.complete = true }
      context "when there are no associated physical objects" do
        it "can be true" do
	  expect(picklist.physical_objects).to be_empty
	  expect(picklist).to be_valid
	end
      end
      context "when all physical objects are packed" do
        before(:each) do
	  physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
	  physical_object.box = box
	  physical_object.save!
	end
        it "can be true" do
	  expect(picklist.physical_objects.packed).not_to be_empty
	  expect(picklist.physical_objects.unpacked).to be_empty
	  expect(picklist).to be_valid
	end
      end
      context "when all unpacked objects are blocked" do
        before(:each) { blocking_condition }
        it "can be true" do
	  expect(picklist.physical_objects.unpacked).not_to be_empty
	  expect(picklist.physical_objects.blocked).not_to be_empty
	  expect(picklist).to be_valid
        end
	it "orphans blocked objects" do
	  picklist.save!
	  physical_object.reload
	  expect(physical_object.picklist).to be_nil
	  expect(picklist.physical_objects).to be_empty
	end
      end
      context "when any unpacked objects are packable" do
        before(:each) { physical_object }
        it "cannot be true" do
	  expect(picklist.physical_objects.unpacked).not_to be_empty
	  expect(picklist.physical_objects.blocked).to be_empty
	  expect(picklist).not_to be_valid
        end
      end
    end
  end

  describe "has relationships:" do
    it "can have physical_objects" do
      expect(picklist.physical_objects).to be_empty
      physical_object.picklist
      expect(picklist.physical_objects).not_to be_empty
    end
    it "can belong to a shipment" do
      valid_picklist.shipment = nil
      expect(valid_picklist).to be_valid
    end
  end

  describe "has virtual attributes:" do
    specify "#spreadsheet_descriptor returns name" do
      expect(picklist.spreadsheet_descriptor).to be == picklist.name
    end
    describe "#all_packed?" do
      context "with no objects" do
        before(:each) { expect(picklist.physical_objects).to be_empty }
        it "returns true" do
          expect(picklist.all_packed?).to eq true
        end
      end
      context "with any unpacked objects" do
        before(:each) { FactoryGirl.create(:physical_object, :barcoded, :boxable, picklist: picklist) }
        before(:each) { expect(picklist.physical_objects).not_to be_empty }
        it "returns true" do
          expect(picklist.all_packed?).to eq false
        end
      end
      context "with only packed objects" do
        before(:each) { FactoryGirl.create(:physical_object, :barcoded, :boxable, box: box, picklist: picklist) }
        before(:each) { expect(picklist.physical_objects).not_to be_empty }
        it "returns false" do
          expect(picklist.all_packed?).to eq true
        end
      end
    end
  end

end
