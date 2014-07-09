require 'rails_helper'

describe Box do

  let(:box) { FactoryGirl.create :box }

  it "provides a physical object count" do
    expect(box.physical_objects_count).to eq 0 
  end

end

