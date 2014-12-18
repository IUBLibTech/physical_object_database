#
#requires let statements:
#object, default_status, new_status, valid_status_values, class_title
#
shared_examples "includes Workflow Status Module" do |status_list|
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
    it "returns nil if nil" do
      object.workflow_status = nil
      expect(object.current_workflow_status).to be_blank
    end
    it "returns blank if blank" do
      object.workflow_status = ""
      expect(object.current_workflow_status).to be_blank
    end
    it "returns current status if present" do
      object.assign_default_workflow_status
      expect(object.current_workflow_status).not_to be_nil
    end
  end
  describe "#current_workflow_status=" do
    before(:each) { object.assign_default_workflow_status }
    describe "(invalid status)" do
      it "does not add a new invalid status" do
        expect{ object.current_workflow_status = "invalid status" }.to raise_error RuntimeError
        expect(object.current_workflow_status).to eq default_status
        expect(object.workflow_statuses.size).to eq 1
      end
    end
    describe "(same status)" do
      it "does not add a new WorkflowStatus object" do
        expect{ object.current_workflow_status = object.current_workflow_status }.not_to change{object.workflow_statuses.size} 
      end
      it "returns status text for the same status" do
        expect(object.current_workflow_status = object.current_workflow_status).to eq object.workflow_status
      end
    end
    describe "(new valid status)" do
      it "sets a new valid status" do
        object.current_workflow_status = new_status
        expect(object.current_workflow_status).to eq new_status
      end
      it "adds a valid status to the workflow status history" do
        expect{ object.current_workflow_status = new_status }.to change{object.workflow_statuses.size}.by(1)
      end
      it "returns a valid status text" do
        expect(object.current_workflow_status = new_status).to eq new_status
      end
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
  # previous and next workflow status are only actually used for Batch
  unless status_list.nil?
    describe "#previous_workflow_status" do
      status_list.each_with_index do |status, index|
        previous_status = index.zero? ? "" : status_list[index-1]
        it "on #{status} returns #{previous_status}" do
          object.current_workflow_status = status
	  expect(object.current_workflow_status).to eq status
          expect(object.previous_workflow_status).to eq previous_status
        end
      end
    end
    describe "#next_workflow_status" do
      status_list.each_with_index do |status, index|
        next_status = (index == status_list.size - 1 ? "" : status_list[index+1])
        it "on #{status} returns #{next_status}" do
          object.current_workflow_status = status
	  expect(object.current_workflow_status).to eq status
          expect(object.next_workflow_status).to eq next_status
        end
      end
    end
  end
end
