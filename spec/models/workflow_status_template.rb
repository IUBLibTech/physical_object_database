require 'rails_helper'

describe WorkflowStatusTemplate do
  let(:workflow_status_template) { FactoryGirl.create(:workflow_status_template) }
  let(:valid_workflow_status_template) { FactoryGirl.build(:workflow_status_template) }

  describe "should be seeded with data:" do
    it "7 batch status_templatees" do
      expect(WorkflowStatusTemplate.where(object_type: "Batch").size).to eq 7
    end
    it "9 bin status_templatees" do
      expect(WorkflowStatusTemplate.where(object_type: "Bin").size).to eq 9
    end
    it "8 physical object status_templatees" do
      expect(WorkflowStatusTemplate.where(object_type: "Physical Object").size).to eq 8
    end
  end

  it "gets a valid workflow status template from FactoryGirl" do
    expect(valid_workflow_status_template).to be_valid
  end

  describe "has required fields:" do
    it "name" do
      valid_workflow_status_template.name = nil
      expect(valid_workflow_status_template).not_to be_valid
    end
    
    it "unique name (for scope of same object type)" do
      workflow_status_template
      expect(valid_workflow_status_template).not_to be_valid
    end
  
    it "allows duplicate names (for different object types)" do
      workflow_status_template
      valid_workflow_status_template.object_type = "Bin"
      expect(valid_workflow_status_template).to be_valid
    end

    it "requires a sequence index" do
      valid_workflow_status_template.sequence_index = nil
      expect(valid_workflow_status_template).not_to be_valid
    end
  end

  describe "has optional fields:" do
    it "description" do
      valid_workflow_status_template.description = nil
      expect(valid_workflow_status_template).to be_valid
    end
  end

  describe "supports object types:" do
    let(:object_types) { valid_workflow_status_template.object_types }
    it "Physical Object" do
      expect(object_types["Physical Object"]).not_to be_nil
    end
    it "Bin" do
      expect(object_types["Bin"]).not_to be_nil
    end
    it "Batch" do
      expect(object_types["Batch"]).not_to be_nil
    end
    it "3 total" do
      expect(object_types.size).to eq 3
    end
  end

  it "#select_options"
  
end
