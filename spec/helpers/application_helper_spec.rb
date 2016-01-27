require "rails_helper"

describe ApplicationHelper do
  let(:valid_barcode) { 40152053079381 }
  let(:invalid_barcode) { 40152053079380 }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, mdpi_barcode: valid_barcode }
  let(:bin) { FactoryGirl.create :bin, mdpi_barcode: valid_barcode }
  let(:box) { FactoryGirl.create :box, mdpi_barcode: valid_barcode }

  describe "::valid_barcode?" do
    it "accepts a 0 barcode" do
      expect(ApplicationHelper.valid_barcode?(0)).to eq true
    end
    it "rejects a nil barcode" do
      expect(ApplicationHelper.valid_barcode?(nil)).to eq false
    end
    it "rejects a short barcode" do
      expect(ApplicationHelper.valid_barcode?(valid_barcode / 10)).to eq false
    end
    it "rejects a long barcode" do
      expect(ApplicationHelper.valid_barcode?(valid_barcode * 10)).to eq false
    end
    it "rejects an invalid barcode" do
      expect(ApplicationHelper.valid_barcode?(invalid_barcode)).to eq false
    end
    it "accepts a valid barcode" do
      expect(ApplicationHelper.valid_barcode?(valid_barcode)).to eq true
    end
  end

  describe "::barcode_assigned?" do
    it "returns bin, if assigned to bin" do
      bin
      expect(ApplicationHelper.barcode_assigned?(bin.mdpi_barcode)).to eq bin
    end
    it "returns box, if assigned to box" do
      box
      expect(ApplicationHelper.barcode_assigned?(box.mdpi_barcode)).to eq box
    end
    it "returns physical object, if assigned to physical object" do
      physical_object
      expect(ApplicationHelper.barcode_assigned?(physical_object.mdpi_barcode)).to eq physical_object
    end
    it "returns false, if not assigned" do
      expect(ApplicationHelper.barcode_assigned?(valid_barcode)).to eq false
    end
    it "prevents barcode re-use" do
      bin
      expect{ box }.to raise_error "Validation failed: Mdpi barcode #{valid_barcode} has already been assigned to a Bin"
    end
  end

  describe "::dp_na(field)" do
    before(:each) { @tm = physical_object.ensure_tm }
    it "returns nil value for required field" do
      expect(dp_na(:filename)).to be_nil
    end
    it "returns nil value for optional field" do
      expect(dp_na(:comments)).to be_nil
    end
    it "returns true value for na field" do
      expect(dp_na(:baking_date)).to eq true
    end
  end

  describe "::dp_requirement(field)" do
    before(:each) { @tm = physical_object.ensure_tm }
    it "returns string value for required field" do
      expect(dp_requirement(:filename)).not_to be_blank
    end
    it "returns nil value for optional field" do
      expect(dp_requirement(:comments)).to be_blank
    end
    it "returns nil value for na field" do
      expect(dp_requirement(:baking_date)).to be_blank
    end
  end

end
