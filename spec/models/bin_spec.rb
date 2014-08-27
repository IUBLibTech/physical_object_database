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
      valid_bin.mdpi_barcode = nil
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
      expect(bin.workflow_statuses.size).to eq 1 #default workflow status
    end
    it "has many condition statuses" do
      expect(bin.condition_statuses.size).to eq 0
    end
    
  end

  describe "provides virtual attributes:" do
    it "provides a spreadsheet descriptor" do
      expect(bin.identifier).to eq(bin.spreadsheet_descriptor)
    end
    it "provides a physical object count" do
      expect(bin.physical_objects_count).to eq 0 
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

  describe "includes WorkflowStatusModule:" do
    it "does WorkflowStatusModule things..." do
      skip "TODO"
    end
  end

end

