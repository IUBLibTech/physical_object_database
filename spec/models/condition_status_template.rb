require 'rails_helper'

describe ConditionStatusTemplate do
  let(:condition_status_template) { FactoryGirl.create(:condition_status_template) }
  let(:valid_condition_status_template) { FactoryGirl.build(:condition_status_template) }

  #no seeded data

  it "gets a valid object from FactoryGirl" do
    expect(valid_condition_status_template).to be_valid
  end

  describe "has required fields" do
    it "name" do
      valid_condition_status_template.name = nil
      expect(valid_condition_status_template).to be_invalid
    end
    it "name unique in scope :object_type" do
      condition_status_template
      expect(valid_condition_status_template).not_to be_valid
    end
    it "name duplicates allowed for different object_type" do
      condition_status_template
      valid_condition_status_template.object_type = "Bin"
      expect(valid_condition_status_template).to be_valid
    end
    it "object_type" do
      expect(valid_condition_status_template.object_type).not_to be_nil
      valid_condition_status_template.object_type = nil
      expect(valid_condition_status_template.object_type).to be_nil
    end
  end

  describe "has optional fields:" do
    it "description" do
      expect(valid_condition_status_template.description).not_to be_nil
      valid_condition_status_template.description = nil
      expect(valid_condition_status_template).to be_valid
    end
  end

  describe "supports object types:" do
    let(:object_types) { valid_condition_status_template.object_types }
    it "Physical Object" do
      expect(object_types["Physical Object"]).not_to be_nil
    end
    it "Bin" do
      expect(object_types["Bin"]).not_to be_nil
    end
    it "2 total" do
      expect(object_types.size).to eq 2
    end
  end


  describe "has relationships:" do
    it "many condition_statuses" do
      expect(valid_condition_status_template.condition_statuses.size).to eq 0
    end
  end

  describe ".select_options(object_type)" do
    let(:select_options) { ConditionStatusTemplate.select_options(condition_status_template.object_type) }
    it "returns name/id hash" do
      expect(select_options[condition_status_template.name]).to eq condition_status_template.id
    end
  end

end
