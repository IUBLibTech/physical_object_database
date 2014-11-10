require 'rails_helper'

describe WorkflowStatusTemplate do
  # need to manually destroy after each creation, as this is a seed data table
  let(:workflow_status_template) { FactoryGirl.create(:workflow_status_template) }
  let(:valid_workflow_status_template) { FactoryGirl.build(:workflow_status_template) }

  describe "should be seeded with data:" do
    seeded_values = { "Batch" => 5, "Bin" => 5, "Physical Object" => 7 }
    seeded_values.each do |object_type, count|
      it "#{count} #{object_type} status_templatees" do
        expect(WorkflowStatusTemplate.where(object_type: object_type).size).to eq count
      end
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
      workflow_status_template.destroy
    end
  
    it "allows duplicate names (for different object types)" do
      workflow_status_template
      valid_workflow_status_template.object_type = "Bin"
      expect(valid_workflow_status_template).to be_valid
      workflow_status_template.destroy
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
    ["Batch", "Bin", "Physical Object"].each do |object_type|
      specify "#{object_type}" do
        expect(object_types[object_type]).not_to be_nil
      end
    end
    it "3 total" do
      expect(object_types.size).to eq 3
    end
  end

  describe "has relationships:" do
    it "many workflow_statuses" do
      expect(valid_workflow_status_template.workflow_statuses.size).to eq 0 
    end
  end

  describe ".select_options(object_type)" do
    let(:select_options) { WorkflowStatusTemplate.select_options(workflow_status_template.object_type) }
    it "returns name/name hash" do
      expect(select_options[workflow_status_template.name]).to eq workflow_status_template.name
      workflow_status_template.destroy
    end
  end

  
end
