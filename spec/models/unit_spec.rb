require 'rails_helper'

describe Unit do

  let(:unit) { FactoryGirl.create :unit }
  let(:duplicate) { FactoryGirl.build :unit }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, unit: unit }
  describe "should be seeded with data:" do
    it "76 values" do
      expect(Unit.all.size).to eq 76
    end
  end
  it "requires an abbreviation" do
    expect(unit.abbreviation).not_to be_blank
    unit.abbreviation = ""
    expect(unit).to be_invalid
  end

  it "requires a unique abbreviation value" do
    expect(duplicate).to be_valid
    unit
    expect(duplicate).to be_invalid
  end

  it "requires a name" do
    expect(unit.name).not_to be_blank
    unit.name = ""
    expect(unit).to be_invalid
  end

  it "requires a unique name value" do
    expect(duplicate).to be_valid
    unit
    expect(duplicate).to be_invalid
  end

  it "can have physical_objects" do
    expect(unit.physical_objects).to be_empty
    physical_object
    expect(unit.physical_objects).not_to be_empty
  end

  it "#spreadsheet_descriptor returns abbreviation" do
    expect(unit.spreadsheet_descriptor).to be == unit.abbreviation
  end

end
