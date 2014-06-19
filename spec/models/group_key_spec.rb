require 'rails_helper'

describe GroupKey do
  let(:group_key) { FactoryGirl.create(:group_key) }
  let(:duplicate_key) { FactoryGirl.create(:group_key, identifier: "foo") }

  it "requires an identifier" do
    group_key.identifier = ""
    expect(group_key).not_to be_valid
  end
  it "requires a unique identifier" do
    duplicate_key.identifier = group_key.identifier
    expect(duplicate_key).not_to be_valid
  end
  it "can have physical objects" do
    expect(group_key.physical_objects).to be_empty
  end
end
