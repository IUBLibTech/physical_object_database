require 'rails_helper'

describe Bin do

  let(:batch) {FactoryGirl.create :batch }
  let(:pl) {}
  let(:bin) { FactoryGirl.create :bin, batch: batch }

  it "can belong to a batch" do
  	expect(batch.bins.where(id: bin.id).first).to eq(bin)
  	expect(bin.batch).to eq batch
  	bin.batch = nil
  	bin.save
  	expect(bin.batch).to eq nil
  	expect(batch.bins.where(id: bin.id).first).to be_nil
  end

  if "can belong to a picklist specification" do

  end

  it "provides a spreadsheet descriptor" do
  	expect(bin.identifier).to eq(bin.spreadsheet_descriptor)
  end

  it "provides a physical object count" do
    expect(bin.physical_objects_count).to eq 0 
  end

end

