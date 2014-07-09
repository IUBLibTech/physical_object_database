require 'rails_helper'

describe Note do
  let(:note) { FactoryGirl.create(:note) }

  it "requires a physical object association" do
    note.physical_object = nil
    expect(note).to be_invalid
  end

  it "requires a username" do
    note.user = nil
    expect(note).to be_invalid
  end

  it "allows body text" do
    note.body = "Test body text"
    expect(note).to be_valid
  end
end
