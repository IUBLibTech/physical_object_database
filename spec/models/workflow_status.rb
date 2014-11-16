require 'rails_helper'

describe WorkflowStatus do
  let(:workflow_status) { FactoryGirl.create(:workflow_status, :physical_object) }
  let(:valid_workflow_status) { FactoryGirl.build(:workflow_status, :physical_object) }

  it "gets a valid workflow status from FactoryGirl" do
    expect(valid_workflow_status).to be_valid
  end

  describe "has required fields:" do
    it "workflow_status_template" do
      valid_workflow_status.workflow_status_template = nil
      expect(valid_workflow_status).not_to be_valid
    end
  end

  describe "has relationships: " do
    it "can belong to a physical object" do
      expect(valid_workflow_status.physical_object).to be_nil
    end
    it "can belong to a batch" do
      expect(valid_workflow_status.batch).to be_nil
    end
    it "can belong to a bin" do
      expect(valid_workflow_status.bin).to be_nil
    end
  end
  
  describe "has virtual attributes:" do
    it "name returns template name" do
      expect(valid_workflow_status.name).to eq valid_workflow_status.workflow_status_template.name
    end
    it "description returns template description" do
      expect(valid_workflow_status.description).to eq valid_workflow_status.workflow_status_template.description
    end
    it "sequence_index returns template sequence_index" do
      expect(valid_workflow_status.sequence_index).to eq valid_workflow_status.workflow_status_template.sequence_index
    end
  end

end
