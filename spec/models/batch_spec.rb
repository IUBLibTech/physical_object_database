require 'rails_helper'

describe Batch do

  let(:batch) { FactoryGirl.create :batch }
  let(:valid_batch) { FactoryGirl.build :batch }
  let(:duplicate) { FactoryGirl.build :batch, identifier: "duplicate" }
  let(:bin) { FactoryGirl.create :bin, batch: batch }
  let(:box) { FactoryGirl.create :box, bin: bin }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }

  it "requires an identifier" do
    expect(batch).to be_valid
    expect(batch.identifier).not_to be_blank
    batch.identifier = ""
    expect(batch).to be_invalid
  end

  it "requires a unique identifier" do
    expect(duplicate).to be_valid
    duplicate.identifier = batch.identifier
    expect(duplicate).to be_invalid
  end

  it "provides a physical object count" do
    expect(batch.physical_objects_count).to eq 0 
  end

  it "has many bins" do
    expect(batch.bins.size).to eq 0
  end

  it "has a default workflow status of Created" do
    expect(duplicate.current_workflow_status.name).to eq "Created"
  end

  it "can have workflow statuses" do
    expect(batch.workflow_statuses.size).to eq 1
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
      physical_object
      physical_object.bin = bin
      physical_object.save
      physical_object.reload
      bin.reload
      expect(bin.boxes).to be_empty
      expect(batch.media_format).to eq physical_object.format
    end
    it "returns format of first object in first box in in first bin" do
      bin
      box
      physical_object.box = box
      physical_object.save
      physical_object.reload
      box.reload
      bin.reload
      expect(batch.media_format).to eq physical_object.format
    end
  end

  it_behaves_like "includes Workflow Status Module" do
    let(:object) { valid_batch }
    let(:default_status) { "Created" }
    let(:new_status) { "Assigned" }
    let(:valid_status_values) { ["Created", "Assigned", "Shipped", "Returned", "Complete"] }
    let(:class_title) { "Batch" }
  end

end

