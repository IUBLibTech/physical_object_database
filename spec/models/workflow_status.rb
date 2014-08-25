require 'rails_helper'

describe WorkflowStatus do
  let(:workflow_status) { FactoryGirl.create(:workflow_status) }
  let(:valid_workflow_status) { FactoryGirl.build(:workflow_status) }

  it "gets a valid workflow status from FactoryGirl" do
    expect(valid_workflow_status).to be_valid
  end

  it "requires a workflow_status_template" do
    valid_workflow_status.workflow_status_template = nil
    expect(valid_workflow_status).not_to be_valid
  end

  describe "relationships: " do
    it "can belong to a physical object"
    it "a batch"
    it "a bin"
  end

end
