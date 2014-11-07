#
#requires let statements:
#object, default_status, new_status, valid_status_values, class_title
#
shared_examples "includes Workflow Status Module" do
  describe "#assign_default_workflow_status" do
    it "assigns default status" do
      object.assign_default_workflow_status
      expect(object.current_workflow_status).to eq default_status
    end
  end
  describe "#class_title" do
    it "returns class title for object type" do
      expect(object.class_title).to eq class_title
    end
  end
  describe "#current_workflow_status" do
    it "returns nil for no statuses" do
      object.workflow_status = nil
      expect(object.current_workflow_status).to be_nil
    end
    it "returns current status if present" do
      object.assign_default_workflow_status
      expect(object.current_workflow_status).not_to be_nil
    end
  end
  describe "#current_workflow_status=" do
    it "does not add a new invalid status" do
      object.assign_default_workflow_status
      object.current_workflow_status = "invalid status"
      expect(object.current_workflow_status).to eq default_status
    end
    it "adds a new valid status" do
      object.assign_default_workflow_status
      object.current_workflow_status = new_status
      expect(object.current_workflow_status).to eq new_status
    end
  end
  describe "#default_workflow_status" do
    it "returns default workflow status for object type" do
      expect(object.default_workflow_status).to eq default_status
    end
  end
  describe "#workflow_status_options" do
    it "returns workflow status options for object type" do
      expect(object.workflow_status_options.keys.sort).to eq valid_status_values.sort
    end
  end
end
