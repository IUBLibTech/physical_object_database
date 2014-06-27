require 'rails_helper'

describe Bin do

  let(:bin) { FactoryGirl.create :bin }

  it "provides a physical object count" do
    expect(bin.physical_objects_count).to eq 0 
  end

end

