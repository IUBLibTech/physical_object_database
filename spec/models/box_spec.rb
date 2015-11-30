describe Box do

  let(:bin) { FactoryGirl.create :bin}
  let(:box) { FactoryGirl.create :box, bin: bin }
  let(:valid_box) { FactoryGirl.build :box }
  let(:invalid_box) { FactoryGirl.build :box, :invalid }
  let(:valid_bin) { FactoryGirl.build :bin }
  let(:boxed_object) { FactoryGirl.create :physical_object, :cdr, :barcoded, box: box}
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }
  let(:open_reel) { FactoryGirl.create :physical_object, :open_reel, :barcoded, bin: bin }
  let(:boxed_object) { FactoryGirl.create :physical_object, :barcoded, :boxable, box: box }

  describe "FactoryGirl" do
    it "gets a valid object by default" do
      expect(valid_box).to be_valid
    end
    it "provides an invalid object with :invalid trait" do
      expect(invalid_box).to be_invalid
    end
  end

  describe "has required attributes" do
    it "requires a barcode" do
      valid_box.mdpi_barcode = nil
      expect(valid_box).not_to be_valid
    end
    it "requires a valid barcode" do
      valid_box.mdpi_barcode = invalid_mdpi_barcode
      expect(valid_box).not_to be_valid
    end
    it "requires a non-zero barcode" do
      valid_box.mdpi_barcode = 0
      expect(valid_box).not_to be_valid
    end
  end

  describe "has optional attributes:" do
    specify "Full boolean" do
      valid_box.full = false
      expect(valid_box).to be_valid
    end
    specify "description text" do
      valid_box.description = nil
      expect(valid_box).to be_valid
    end
    describe "format" do
      specify "is optional" do
        valid_box.format = nil
        expect(valid_box).to be_valid
      end
      specify "is automatically set by first contained object" do
        expect(box.format).to be_nil
        boxed_object
        box.reload
        expect(box.format).to eq boxed_object.format
      end
    end
  end

  describe "has relationships:" do
    it "has many physical_objects" do 
  	  expect(box.physical_objects).to be_empty	
  	  boxed_object # a reference to the physcical object is necessary to "load" it into the rspec framework
  	  expect(box.physical_objects).not_to be_empty
  	  expect(box.physical_objects_count).to eq 1   	
    end
    it "updates physical objects workflow status when destroyed" do
      expect(boxed_object.workflow_status).to eq "Boxed"
      box.destroy
      boxed_object.reload
      expect(boxed_object.workflow_status).not_to eq "Boxed"
    end
    it "can belong to a bin if barcode is set (which it must be to be valid)" do
  	  valid_box.bin = bin
	  expect(valid_box).to be_valid
    end
    it "cannot belong to a bin if barcode is not set" do
    	valid_box.mdpi_barcode = "0"
	    valid_box.bin = bin
	    expect(valid_box).not_to be_valid
    end
    it "cannot belong to a bin containing physical objects" do
      open_reel
      valid_box.bin = bin
      expect(valid_box).not_to be_valid
    end
    it "can belong to a bin of unspecified format" do
      valid_bin.format = nil
      valid_box.format = TechnicalMetadatumModule.box_formats.first
      valid_box.bin = valid_bin
      expect(valid_box).to be_valid
    end
    it "can belong to a bin of matching format" do
      valid_bin.format = TechnicalMetadatumModule.box_formats.first
      valid_box.format = TechnicalMetadatumModule.box_formats.first
      valid_box.bin = valid_bin
      expect(valid_box).to be_valid
    end
    it "cannot belong to a bin of mismatched format" do
      valid_bin.format = TechnicalMetadatumModule.box_formats.first
      valid_box.format = TechnicalMetadatumModule.box_formats.last
      valid_box.bin = valid_bin
      expect(valid_box).not_to be_valid
    end
    it "cannot belong to a format-specific bin if format unset" do
      valid_bin.format = TechnicalMetadatumModule.box_formats.first
      valid_box.format = ""
      valid_box.bin = valid_bin
      expect(valid_box).not_to be_valid
    end
    it "can belong to a spreadsheet" do
      expect(box.spreadsheet).to be_nil
    end
  end

  describe "has virtual attributes:" do
    it "provides a spreadsheet descriptor" do
  	  expect(box.spreadsheet_descriptor).to eq(box.mdpi_barcode)
    end
    it "provides a physical object count" do
      expect(box.physical_objects_count).to eq 0 
    end
  end

  describe "#media_format" do
    context "without any objects" do
      it "returns nil" do
        expect(box.physical_objects).to be_empty
        expect(box.media_format).to be_nil
      end
    end
    context "with at least one object" do
      it "returns format of first object" do
        boxed_object
        expect(box.media_format).not_to be_nil
        expect(box.media_format).to eq boxed_object.format
      end
    end
  end

  describe "#packed_status?" do
    it "returns true if associated to a bin" do
      expect(box.bin).not_to be_nil
      expect(box.packed_status?).to eq true
    end
    it "returns false if not associated to a bin" do
      box.bin = nil
      expect(box.packed_status?).to eq false
    end
  end

  describe "::packed_status_message" do
    it "returns a message that the Box is full" do
      expect(Box.packed_status_message).to match /This box.*full/
    end
  end


end

