#
#requires let statements:
#object, default_status, new_status, valid_status_values, class_title
#
shared_examples "includes WorkflowStatusModule" do |status_list|
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
    context "(invalid status)" do
      it "does not add a new invalid status" do
        expect{ object.current_workflow_status = "invalid status" }.to raise_error RuntimeError
        expect(object.current_workflow_status).to eq default_status
        expect(object.workflow_statuses.size).to eq 1
      end
    end
    context "(same status)" do
      it "does not add a new WorkflowStatus object" do
        expect{ object.current_workflow_status = object.current_workflow_status }.not_to change{object.workflow_statuses.size} 
      end
      it "returns status text for the same status" do
        expect(object.current_workflow_status = object.current_workflow_status).to eq object.workflow_status
      end
    end
    context "(new valid status)" do
      it "sets a new valid status" do
        object.current_workflow_status = new_status
        expect(object.current_workflow_status).to eq new_status
        expect(object.workflow_status).to eq new_status
      end
      it "sets a new workflow_index value" do
        original_workflow_index = object.workflow_index
        object.current_workflow_status = new_status
	expect(object.workflow_index).not_to eq original_workflow_index
	expect(object.workflow_index).to eq object.workflow_statuses.last.workflow_status_template.sequence_index
      end
      it "adds a valid status to the workflow status history" do
        expect{ object.current_workflow_status = new_status }.to change{object.workflow_statuses.size}.by(1)
      end
      it "returns a valid status text" do
        expect(object.current_workflow_status = new_status).to eq new_status
      end
    end
  end
  describe "#duplicate_workflow_status" do
    context "when an object has no workflow statuses" do
      before(:each) { object.workflow_statuses = [] }
      it "does nothing" do
        expect(object.workflow_statuses).to be_empty
        object.duplicate_workflow_status
	expect(object.workflow_statuses).to be_empty
      end
    end
    context "when an object has at least one workflow status" do
      it "creates a duplicate workflow status" do
        object.save
        expect{object.duplicate_workflow_status}.to change{object.workflow_statuses.size}.by(1)
	expect(object.workflow_statuses[-1].workflow_status_template_id).to eq object.workflow_statuses[-2].workflow_status_template_id
      end
    end
  end
  describe "#default_workflow_status" do
    it "returns default workflow status for object type" do
      expect(object.default_workflow_status).to eq default_status
    end
  end
  describe "#inferred_workflow_status" do
    it "returns a string" do
      expect(object.inferred_workflow_status).to be_a String
    end
  end
  describe "#display_workflow_status" do
    it "returns current_workflow_status" do
      expect(object.display_workflow_status).to eq object.current_workflow_status
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
