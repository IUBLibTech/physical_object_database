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
  let(:binned_object) { FactoryGirl.create :physical_object, :barcoded, :binnable, bin: bin }

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
      specify "is automatically set by bin assignment (pre-validation)" do
        valid_bin.format = TechnicalMetadatumModule.box_formats.first
        valid_box.bin = valid_bin
        expect(valid_box.format).to be_blank
        expect(valid_box).to be_valid
        expect(valid_box.format).not_to be_blank
        expect(valid_box.format).to eq valid_bin.format
      end
    end
    describe "physical location" do
      it "can be blank" do
        valid_box.physical_location = ''
        expect(valid_box).to be_valid
      end
      it "cannot be nil" do
        valid_box.physical_location = nil
        expect(valid_box).not_to be_valid
      end
      it "must be a valid value from list" do
        valid_box.physical_location = "invalid value"
        expect(valid_box).not_to be_valid
      end
      it "is set as a default value" do
        valid_box.physical_location = nil
        valid_box.default_values
        expect(valid_box.physical_location).not_to be_nil
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
    it "can belong to a format-specific bin if format unset (auto-setting format)" do
      valid_bin.format = TechnicalMetadatumModule.box_formats.first
      valid_box.format = ""
      valid_box.bin = valid_bin
      expect(valid_box).to be_valid
      expect(valid_box.format).not_to be_blank
      expect(valid_box.format).to eq valid_bin.format
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

  describe "#set_container_format" do
    context "in a bin" do
      before(:each) do
        valid_box.format = "CD-R"
        valid_box.bin = bin
      end
      let(:contained) { valid_box }
      let(:container) { bin }
      include_examples "nil and blank format cases"
    end
  end

  describe "::packed_status_message" do
    it "returns a message that the Box is full" do
      expect(Box.packed_status_message).to match /This box.*full/
    end
  end

  include_examples "default_values examples", { full: false, description: '' } do
    let(:target_object) { valid_box }
  end

  describe "#set_format_from_container" do
    context "with a format already set" do
      before(:each) { valid_box.format = "CD-R" }
      it "returns nil" do
        expect(valid_box.set_format_from_container).to be_nil
      end
    end
    context "without a format" do
      before(:each) { expect(valid_box.format).to be_nil }
      context "with no bin" do
        before(:each) { expect(valid_box.bin).to be_nil }
        it "returns nil" do
          expect(valid_box.set_format_from_container).to be_nil
        end
      end
      context "with an assigned bin" do
        before(:each) { valid_box.bin = bin }
        context "without a format" do
          before(:each) { bin.format = nil }
          it "returns nil" do
            expect(valid_box.set_format_from_container).to be_nil
          end
        end
        context "with a format" do
          before(:each) { bin.format = "CD-R" }
          it "assigns the bin format to the box" do
            expect(valid_box.set_format_from_container).to eq bin.format
            expect(valid_box.format).to eq bin.format
          end
        end
      end
    end
  end

  describe "#validate_bin_container" do
    context "with no bin" do
      before(:each) { expect(valid_box.bin).to be_nil }
      it "returns nil" do
        expect(valid_box.validate_bin_container).to be_nil
        expect(valid_box.errors).to be_empty
      end
    end
    context "with an bin with objects" do
      before(:each) { valid_box.bin = bin; binned_object }
      it "adds error" do
        expect(valid_box.validate_bin_container).not_to be_nil
        expect(valid_box.errors.full_messages.first).to match /contains physical objects/
      end
    end
    context "with an empty bin" do
      before(:each) { valid_box.bin = bin; bin.format }
      context "with an unformatted bin" do
        before(:each) { bin.format = nil }
        it "returns nil" do
          expect(valid_box.validate_bin_container).to be_nil
          expect(valid_box.errors).to be_empty
        end
      end
      context "with a formatted bin" do
        context "with no box format" do
          before(:each) { bin.format = "CD-R" }
          it "returns error" do
            expect(valid_box.validate_bin_container).not_to be_nil
            expect(valid_box.errors.full_messages.first).to match /must have a format/
          end
        end
        context "with mismatching format" do
          before(:each) { bin.format = "CD-R"; valid_box.format = "CD-R" }
          it "returns nil" do
            expect(valid_box.validate_bin_container).to be_nil
            expect(valid_box.errors).to be_empty
          end
        end
        context "with mismatching format" do
          before(:each) { bin.format = "Betacam"; valid_box.format = "CD-R" }
          it "returns error" do
            expect(valid_box.validate_bin_container.first).to match /different format/
          end
        end
      end
    end
  end
end

