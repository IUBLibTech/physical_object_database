require 'rails_helper'

describe Unit do

  let(:unit) { FactoryGirl.create :unit }
  let(:valid_unit) { FactoryGirl.build :unit }
  let(:invalid_unit) { FactoryGirl.build :unit, :invalid }
  let(:duplicate) { FactoryGirl.build :unit }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, unit: unit }
  describe "should be seeded with data:" do
    it "78 values" do
      expect(Unit.all.size).to be >= 78
    end
  end
  describe "FactoryGirl object generation" do
    it "returns a valid unit" do
      expect(valid_unit).to be_valid
    end
    it "returns an invalid unit" do
      expect(invalid_unit).not_to be_valid
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
      unit.destroy!
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
      unit.destroy!
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
      physical_object.destroy!
      unit.destroy!
    end

    it "cannot be destroyed if it has associated physical objects" do
      physical_object
      expect(unit.destroy).to eq false
      physical_object.destroy!
      unit.destroy!
    end

  end

  describe "has virtual fields:" do
    specify "#spreadsheet_descriptor returns abbreviation" do
      expect(valid_unit.spreadsheet_descriptor).to be == valid_unit.abbreviation
    end
    describe "#home" do
      context "without an institution set" do
        before(:each) { valid_unit.institution = "" }
        it "returns the campus" do
          expect(valid_unit.home).to eq valid_unit.campus.to_s
        end
      end
      context "with an institution set" do
        before(:each) { valid_unit.institution = "Indiana University" }
        it "returns institution-campus" do
          expect(valid_unit.home).to eq "#{valid_unit.institution}-#{valid_unit.campus.to_s}"
        end
      end
    end
  end

end
