require 'rails_helper'

describe Picklist do

  let(:picklist) { FactoryGirl.create :picklist }
  let(:duplicate) { FactoryGirl.build :picklist }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, picklist: picklist }

  it "requires a name" do
    expect(picklist.name).not_to be_blank
    picklist.name = ""
    expect(picklist).to be_invalid
  end

  it "requires a unique name" do
    expect(duplicate).to be_valid
    picklist
    expect(duplicate).to be_invalid
  end

  it "allows a description" do
    expect(picklist.description).not_to be_blank
    picklist.description = ""
    expect(picklist).to be_valid
  end

  it "can have physical_objects" do
    expect(picklist.physical_objects).to be_empty
    physical_object.picklist
    expect(picklist.physical_objects).not_to be_empty
  end

  it "#spreadsheet_descriptor returns name" do
    expect(picklist.spreadsheet_descriptor).to be == picklist.name
  end

end
