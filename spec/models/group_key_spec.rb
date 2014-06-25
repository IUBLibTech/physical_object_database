require 'rails_helper'

describe GroupKey do
  let(:group_key) { FactoryGirl.create(:group_key) }

  it "can have physical objects" do
    expect(group_key.physical_objects).to be_empty
  end
  it "caches physical objects count" do
    expect(group_key.physical_objects_count.to_i).to eq 0
  end
end
