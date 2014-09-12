require 'rails_helper'

describe CdrTm do

  let(:cdr_tm) {FactoryGirl.build :cdr_tm }

  it "gets a valid object from FactoryGirl" do
    expect(cdr_tm).to be_valid
  end

  describe "has required fields:" do
    it "damage" do
      cdr_tm.damage = nil
      expect(cdr_tm).not_to be_valid
    end
    it "damage in values list" do
      cdr_tm.damage = "invalid value"
      expect(cdr_tm).not_to be_valid
    end
    it "format_duration" do
      cdr_tm.format_duration = nil
      expect(cdr_tm).not_to be_valid
    end
    it "format_duration in values list" do
      cdr_tm.format_duration = "invalid value"
      expect(cdr_tm).not_to be_valid
    end
  end
 
  #FIXME: abstract out boolean fieldset verification
  #FIXME: abstract out controlled fieldset verification?
  describe "has boolean fieldsets:" do
    describe "preservation problems" do
      CdrTm::PRESERVATION_PROBLEM_FIELDS.each do |field|
        it "includes boolean field: #{field}" do
          expect(cdr_tm.send(field.to_sym)).to eq false
	end
      end
    end
  end

  describe "has relationships:" do
    it "can belong to a picklist specification" do
      expect(cdr_tm.picklist_specification).to be_nil
    end
    it "can belong to a physical object" do
      expect(cdr_tm.physical_object).to be_nil
    end
  end

end

