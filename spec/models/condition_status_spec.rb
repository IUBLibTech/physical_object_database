require 'rails_helper'

describe ConditionStatus do
  let(:condition_status) { FactoryGirl.create(:condition_status, :physical_object) }
  let(:valid_condition_status) { FactoryGirl.build(:condition_status, :physical_object) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr) }

  it "gets a valid object from FactoryGirl" do
    expect(valid_condition_status).to be_valid
  end

  describe "has required fields:" do
  
    specify "condition_status_template" do
      condition_status.condition_status_template = nil
      expect(condition_status).not_to be_valid
    end

    specify "condition_status_template unique for a given physical_object" do
      condition_status.physical_object = physical_object
      condition_status.save
      condition_status.reload
      valid_condition_status.physical_object = physical_object
      valid_condition_status.condition_status_template = condition_status.condition_status_template
      expect(valid_condition_status).not_to be_valid
    end

    specify "condition_status_template unique for a given bin" do
      skip "No condition statuses defined yet for Bins"
    end

    specify "condition_status_template duplicate allowed for different physical_object,bin" do
      condition_status.physical_object = physical_object
      condition_status.save
      condition_status.reload
      valid_condition_status.bin = bin
      expect(valid_condition_status).to be_valid
    end
  
    specify "user" do
      condition_status.user = nil
      expect(condition_status).not_to be_valid
    end

  end

  describe "active attribute" do
    it "status is active on create" do
      expect(condition_status.active).to eq true
      condition_status.active = false
      expect(condition_status.active).to eq false
    end
  end

  describe "has relationships:" do
    it "can belong to a physical object" do
      expect(valid_condition_status.physical_object).to be_nil
    end
    it "can belong to a bin" do
      expect(valid_condition_status.bin).to be_nil
    end
  end

   describe "has virtual attributes:" do
    it "name returns condition_status_template name" do
      expect(valid_condition_status.name).to eq valid_condition_status.condition_status_template.name
    end
    it "description returns condition_status_template_name" do
      expect(valid_condition_status.description).to eq valid_condition_status.condition_status_template.description
    end
  end

  include_examples "has user field" do
    let(:target_object) { valid_condition_status }
  end
 
end
