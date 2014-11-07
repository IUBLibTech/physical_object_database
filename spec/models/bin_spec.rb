require 'rails_helper'

describe Bin do

  let(:batch) {FactoryGirl.create :batch }
  let(:pl) {}
  let(:bin) { FactoryGirl.create :bin, batch: batch }
  let(:valid_bin) { FactoryGirl.build :bin }

  it "gets a valid object from FactoryGirl" do
    expect(valid_bin).to be_valid
  end

  describe "has required fields:" do
    it "identifier" do
      valid_bin.identifier = nil
      expect(valid_bin).not_to be_valid
    end
    it "identifier unique" do
      bin
      expect(valid_bin).not_to be_valid
      valid_bin.identifier = bin.identifier + "_different"
      expect(valid_bin).to be_valid
    end
    it "mdpi_barcode by mdpi_barcode validation" do
      valid_bin.mdpi_barcode = invalid_mdpi_barcode
      expect(valid_bin).not_to be_valid
    end
  end
  
  describe "has optional fields" do
    it "description" do
      valid_bin.description = nil
      expect(valid_bin).to be_valid
    end
  end

  describe "has relationships:" do
    it "can belong to a batch" do
      expect(batch.bins.where(id: bin.id).first).to eq(bin)
      expect(bin.batch).to eq batch
      bin.batch = nil
      bin.save
      expect(bin.batch).to eq nil
      expect(batch.bins.where(id: bin.id).first).to be_nil
    end
    it "can belong to a picklist specification" do
      expect(bin.picklist_specification).to be_nil
    end
    it "can belong to a spreadsheet" do
      expect(bin.spreadsheet).to be_nil
    end
    it "has many physical objects" do
      expect(bin.physical_objects.size).to eq 0
    end
    it "has many boxed_physical_objects" do
      expect(bin.boxed_physical_objects.size).to eq 0
    end
    it "has many boxes" do
      expect(bin.boxes.size).to eq 0
    end
    it "has many workflow statuses" do
      expect(bin.workflow_statuses.size).to be >= 0
    end
    it "has many condition statuses" do
      expect(bin.condition_statuses.size).to be >= 0
    end
    
  end

  describe "provides virtual attributes:" do
    it "provides a spreadsheet descriptor" do
      expect(bin.identifier).to eq(bin.spreadsheet_descriptor)
    end
    it "provides a physical object count" do
      expect(bin.physical_objects_count).to eq 0 
    end
    describe "#packed_status?" do
      it "returns true if in Sealed status" do
	bin.current_workflow_status = "Sealed"
        expect(bin.packed_status?).to eq true
      end
      it "returns false if not in Sealed status" do
        expect(bin.current_workflow_status).not_to eq "Sealed"
        expect(bin.packed_status?).to eq false
      end
    end
  end

  describe "::packed_status_message" do
    it "returns a message that the Bin is in Sealed status" do
      expect(Bin.packed_status_message).to match /This bin has been marked as sealed/
    end
  end
  
  describe "includes ConditionStatusModule:" do
    let(:condition_status_template) { FactoryGirl.create(:condition_status_template, object_type: "Bin") }
    let(:condition_status) { FactoryGirl.create(:condition_status, bin: bin, condition_status_template: condition_status_template) }
    it "#class_title returns 'Bin'" do
      expect(valid_bin.class_title).to eq "Bin"
    end
    it "#condition_status_options returns status options" do
      condition_status
      expect(bin.condition_status_options.first.first).to eq condition_status.name
      expect(bin.condition_status_options.size).to eq 1
    end
    it "#has_condition(object, status_name) returns true/false for object, status_name" do
      expect(ConditionStatusModule.has_condition?(bin, condition_status.name)).to be true
      expect(ConditionStatusModule.has_condition?(bin, "foo")).to be false
    end
  end

  it_behaves_like "includes Workflow Status Module" do
    let(:object) { valid_bin }
    let(:default_status) { "Created" }
    let(:new_status) { "Sealed" }
    let(:valid_status_values) { ["Created", "Sealed", "Batched", "Returned to Staging Area", "Unpacked"] }
    let(:class_title) { "Bin" }
  end

end

