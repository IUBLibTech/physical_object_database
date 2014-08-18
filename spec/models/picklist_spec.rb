require 'rails_helper'

describe Picklist do

  let(:picklist) { FactoryGirl.create :picklist }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, picklist: picklist }

  it "requires a name" do
    expect(picklist.name).not_to be_blank
    picklist.name = ""
    expect(picklist).to be_invalid
  end

  it "allows a description" do
    expect(picklist.description).not_to be_blank
    picklist.description = ""
    expect(picklist).to be_valid
  end

  it "can have physical_objects" do
    expect(picklist.physical_objects).to be_empty
    physical_object.picklist #referencing physical_object loads it into memory
    expect(picklist.physical_objects).not_to be_empty
  end

  it "#spreadsheet_descriptor returns name" do
    expect(picklist.spreadsheet_descriptor).to be == picklist.name
  end

end
