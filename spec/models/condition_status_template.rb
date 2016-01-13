require 'rails_helper'

describe ConditionStatusTemplate do
  let(:condition_status_template) { FactoryGirl.create(:condition_status_template) }
  let(:valid_condition_status_template) { FactoryGirl.build(:condition_status_template) }
  let(:invalid_condition_status_template) { FactoryGirl.build(:condition_status_template, :invalid) }

  describe "should be seeded with data:" do
    seeded_values = { "Bin" => 0, "Physical Object" => 9 }
    seeded_values.each do |object_type, count|
      specify "#{count} #{object_type} status_templates" do
        expect(ConditionStatusTemplate.where(object_type: object_type).size).to eq count
      end
    end
  end

  describe "FactoryGirl" do
    it "returns a valid object" do
      expect(valid_condition_status_template).to be_valid
    end
    it "returns an invalid object" do
      expect(invalid_condition_status_template).not_to be_valid
    end
  end

  describe "has required fields" do
    it "name" do
      valid_condition_status_template.name = nil
      expect(valid_condition_status_template).to be_invalid
    end
    it "name unique in scope :object_type" do
      condition_status_template
      expect(valid_condition_status_template).not_to be_valid
      condition_status_template.destroy
    end
    it "name duplicates allowed for different object_type" do
      condition_status_template
      valid_condition_status_template.object_type = "Bin"
      expect(valid_condition_status_template).to be_valid
      condition_status_template.destroy
    end
    it "object_type" do
      valid_condition_status_template.object_type = nil
      expect(valid_condition_status_template).not_to be_valid
    end
    it "object_type in OBJECT_TYPES list" do
      valid_condition_status_template.object_type = "invalid value"
      expect(valid_condition_status_template).not_to be_valid
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
      condition_status_template.destroy
    end
  end

end
