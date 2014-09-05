require 'rails_helper'

describe Note do
  let(:note) { FactoryGirl.create(:note) }
  let(:valid_note) { FactoryGirl.build(:note) }

  it "gets a valid object from FactoryGirl" do
    expect(valid_note).to be_valid
  end

  it "requires a physical object association" do
    valid_note.physical_object = nil
    expect(valid_note).to be_invalid
  end

  it "requires a username" do
    valid_note.user = nil
    expect(valid_note).to be_invalid
  end

  it "allows body text" do
    valid_note.body = ""
    expect(valid_note).to be_valid
  end

  describe "#default_values" do
    let(:default_values) { valid_note.user = nil; valid_note.default_values }
    it "assigns a user value" do
      default_values
      expect(valid_note.user).not_to be_nil
    end
  
    it "gets session[:username] as default username" do
      sign_in("user@example.com")
      default_values
      expect(valid_note.user).to eq "user@example.com"
    end
  
    it "gets UNAVAILABLE as default username if unavailable from session" do
      sign_out
      default_values
      expect(valid_note.user).to eq "UNAVAILABLE"
    end
  end
end
