require 'rails_helper'

describe Unit do

  let(:unit) { FactoryGirl.create :unit }
  let(:valid_unit) { FactoryGirl.build :unit }
  let(:duplicate) { FactoryGirl.build :unit }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, unit: unit }
  describe "should be seeded with data:" do
    it "77 values" do
      expect(Unit.all.size).to eq 77
    end
  end
  describe "FactoryGirl object generation" do
    it "returns a valid unit" do
      expect(valid_unit).to be_valid
    end
  end
  describe "has required fields:" do
    it "requires an abbreviation" do
      expect(valid_unit.abbreviation).not_to be_blank
      valid_unit.abbreviation = ""
      expect(valid_unit).to be_invalid
    end

    it "requires a unique abbreviation value" do
      expect(duplicate).to be_valid
      unit
      expect(duplicate).to be_invalid
      unit.destroy
    end
  
    it "requires a name" do
      expect(valid_unit.name).not_to be_blank
      valid_unit.name = ""
      expect(valid_unit).to be_invalid
    end
  
    it "requires a unique name value" do
      expect(duplicate).to be_valid
      unit
      expect(duplicate).to be_invalid
      unit.destroy
    end
  end

  describe "has optional fields:" do

    it "can have an institution" do
      valid_unit.institution = ""
      expect(valid_unit).to be_valid
    end

    it "can have a campus" do
      valid_unit.campus = ""
      expect(valid_unit).to be_valid
    end

    it "can have physical_objects" do
      expect(unit.physical_objects).to be_empty
      physical_object
      expect(unit.physical_objects).not_to be_empty
      unit.destroy
    end
  end

  describe "has virtual fields:" do
    specify "#spreadsheet_descriptor returns abbreviation" do
      expect(valid_unit.spreadsheet_descriptor).to be == valid_unit.abbreviation
    end
  end

end
