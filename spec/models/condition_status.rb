require 'rails_helper'

describe ConditionStatus do
  let(:condition_status_template) { FactoryGirl.create(:condition_status_template) }
  let(:condition_status) { FactoryGirl.create(:condition_status, condition_status_template: condition_status_template) }
  let(:valid_condition_status) { FactoryGirl.build(:condition_status, condition_status_template: condition_status_template) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr) }

  it "gets a valid object from FactoryGirl" do
    expect(valid_condition_status).to be_valid
  end

  describe "has required fields:" do
  
    it "condition_status_template" do
      condition_status.condition_status_template = nil
      expect(condition_status).not_to be_valid
    end

    it "condition_status_template unique for physical_object,bin" do
      condition_status.physical_object = physical_object
      condition_status.save
      condition_status.reload
      valid_condition_status.physical_object = physical_object
      expect(valid_condition_status).not_to be_valid
    end

    it "condition_status_template duplicate allowed for different physical_object,bin" do
      condition_status.physical_object = physical_object
      condition_status.save
      condition_status.reload
      valid_condition_status.bin = bin
      expect(valid_condition_status).to be_valid
    end
  
    it "user" do
      condition_status.user = nil
      expect(condition_status).not_to be_valid
    end

  end

  describe "has relationships:" do
    it "physical object"
    it "bin"
  end

  describe "has virtual attributes:" do
    it "name"
    it "description"
  end
  
end
