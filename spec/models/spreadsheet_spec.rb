require 'rails_helper'

describe Spreadsheet do
  let(:spreadsheet) { FactoryGirl.create :spreadsheet }
  let(:valid_spreadsheet) { FactoryGirl.build :spreadsheet }

  it "gets a valid object from FactoryGirl" do
    expect(valid_spreadsheet).to be_valid
  end

  describe "has required fields: " do
    it "filename is required" do
      valid_spreadsheet.filename = ""
      expect(valid_spreadsheet).not_to be_valid
    end
    it "filename must be unique" do
      valid_spreadsheet.filename = spreadsheet.filename
      expect(valid_spreadsheet).not_to be_valid
    end
  end

  describe "has optional fields: " do
    it "note is optional" do
      valid_spreadsheet.note = nil
      expect(valid_spreadsheet).to be_valid
    end
  end

  describe "relationships:" do
    it "has many bins" do
      expect(valid_spreadsheet.bins.size).to eq 0
    end
    it "has many boxes" do
      expect(valid_spreadsheet.boxes.size).to eq 0
    end
    it "has many physical objects" do
      expect(valid_spreadsheet.physical_objects.size).to eq 0
    end
  end

end
