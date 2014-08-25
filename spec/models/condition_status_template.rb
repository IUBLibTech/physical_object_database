require 'rails_helper'

describe ConditionStatusTemplate do
  let(:condition_status_template) { FactoryGirl.create(:condition_status_template) }
  let(:valid_condition_status_template) { FactoryGirl.build(:condition_status_template) }


  it "gets a valid object from FactoryGirl" do
    expect(valid_condition_status_template).to be_valid
  end

  describe "has required fields" do
    it "name" do
      valid_condition_status_template.name = nil
      expect(valid_condition_status_template).to be_invalid
    end
    it "name unique in scope :object_type"
    it "name duplicates allowed for different object_type"
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

  describe "has relationships:" do
    it "many condition_statuses" do
      expect(valid_condition_status_template.condition_statuses.size).to eq 0
    end
  end

end
