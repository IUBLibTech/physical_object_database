require 'rails_helper'

describe Batch do

  let(:batch) { FactoryGirl.create :batch }

  it "provides a physical object count" do
    expect(batch.physical_objects_count).to eq 0 
  end

end

