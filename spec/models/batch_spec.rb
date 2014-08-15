require 'rails_helper'

describe Batch do

  let(:batch) { FactoryGirl.create :batch }
  let(:duplicate) { FactoryGirl.build :batch, identifier: "duplicate" }

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

end

