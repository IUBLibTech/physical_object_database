require 'rails_helper'

describe Batch do

  let(:batch) { FactoryGirl.create :batch }
  let(:valid_batch) { FactoryGirl.build :batch }
  let(:invalid_batch) { FactoryGirl.build :invalid_batch }
  let(:duplicate) { FactoryGirl.build :batch, identifier: "duplicate" }
  let(:bin) { FactoryGirl.create :bin, batch: batch }
  let(:box) { FactoryGirl.create :box, bin: bin }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }

  describe "FactoryGirl" do
    it "provides a valid batch" do
      expect(valid_batch).to be_valid
    end
    it "provides an invalid batch" do
      expect(invalid_batch).not_to be_valid
    end
  end

  include_examples "destination module examples", FactoryGirl.build(:batch)

  describe "has required fields:" do
    it "requires an identifier" do
      expect(valid_batch.identifier).not_to be_blank
      valid_batch.identifier = ""
      expect(valid_batch).to be_invalid
    end
    it "requires a unique identifier" do
      expect(duplicate).to be_valid
      duplicate.identifier = batch.identifier
      expect(duplicate).to be_invalid
    end
  end

  describe "has relationships:" do
    it "provides a physical object count" do
      expect(batch.physical_objects_count).to eq 0 
    end
    it "has many bins" do
      expect(batch.bins.size).to eq 0
    end
    it "can have workflow statuses" do
      expect(batch.workflow_statuses.size).to be >= 0
    end
    it "has a default workflow status of Created" do
      expect(batch.current_workflow_status).to eq "Created"
    end
  end

  describe "#media_format" do
    it "returns nil if no bins" do
      expect(batch.bins.empty?).to be true
      expect(batch.media_format).to be nil
    end
    it "returns nil if no physical objects" do
      bin
      expect(batch.bins.empty?).to be false
      expect(batch.bins.first.physical_objects).to be_empty
      expect(batch.media_format).to be nil
    end
    it "returns format of first object in first bin" do
      bin
      physical_object.format = "Open Reel Audio Tape"
      physical_object.bin = bin
      physical_object.save!
      physical_object.reload
      bin.reload
      expect(bin.boxes).to be_empty
      expect(batch.media_format).to eq physical_object.format
    end
    it "returns format of first object in first box in in first bin" do
      bin
      box
      physical_object.box = box
      physical_object.save!
      physical_object.reload
      box.reload
      bin.reload
      expect(batch.media_format).to eq physical_object.format
    end
  end
  
  describe "#packed_status?" do
    it "returns false if Created" do
      expect(batch.packed_status?).to eq false
    end
    it "returns true for other status" do
      batch.current_workflow_status = "Assigned"
      expect(batch.packed_status?).to eq true
    end
  end

  status_list = ["Created", "Assigned", "Shipped", "Returned", "Complete"]
  # pass status_list arg here to test previous/next methods
  it_behaves_like "includes Workflow Status Module", status_list do
    let(:object) { valid_batch }
    let(:default_status) { "Created" }
    let(:new_status) { "Assigned" }
    let(:valid_status_values) { status_list }
    let(:class_title) { "Batch" }
  end

end

