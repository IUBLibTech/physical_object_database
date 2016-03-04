describe WorkflowStatus do
  let(:workflow_status) { FactoryGirl.create(:workflow_status, :physical_object) }
  let(:valid_workflow_status) { FactoryGirl.build(:workflow_status, :physical_object) }
  let(:physical_object) { FactoryGirl.create(:physical_object, :boxable) }
  let(:batch) { FactoryGirl.create(:batch) }
  let(:bin) { FactoryGirl.create(:bin) }

  it "gets a valid workflow status from FactoryGirl" do
    expect(valid_workflow_status).to be_valid
  end

  describe "has required fields:" do
    it "workflow_status_template" do
      valid_workflow_status.workflow_status_template = nil
      expect(valid_workflow_status).not_to be_valid
    end
    specify "user" do
      valid_workflow_status.user = nil
      expect(valid_workflow_status).not_to be_valid
    end
  end

  describe "has optional fields:" do
    specify "notes" do
      valid_workflow_status.notes = nil
      expect(valid_workflow_status).to be_valid
    end
    skip "NOTES DEPRECATED HERE?"
  end

  describe "has ephemera tracking fields:" do
    describe "has_ephemera" do
      specify "boolean trait exists" do
        expect(valid_workflow_status).to respond_to(:has_ephemera?)
      end
    end
    describe "ephemera_returned" do
      specify "boolean trait exists" do
        expect(valid_workflow_status).to respond_to(:ephemera_returned?)
      end
    end
    describe "ephemera_okay" do
      specify "boolean trait exists" do
        expect(valid_workflow_status).to respond_to(:ephemera_okay?)
      end
    end
    describe "#set_ephemera_values" do
      shared_examples "leaves nil values" do
        it "leaves nil values" do
	  expect(ws.has_ephemera).to be_nil
	  expect(ws.ephemera_returned).to be_nil
	  expect(ws.ephemera_okay).to be_nil
	end
      end
      context "on a Batch" do
        subject(:ws) { batch.workflow_statuses.last }
        include_examples "leaves nil values"
      end
      context "on a Bin" do
        subject(:ws) { bin.workflow_statuses.last }
        include_examples "leaves nil values"
      end
      { "Boxed, no ephemera" =>		{ workflow_status: "Boxed", has_ephemera: false, ephemera_returned: false, ephemera_okay: nil },
        "Boxed, with ephemera" =>	{ workflow_status: "Boxed", has_ephemera: true, ephemera_returned: false, ephemera_okay: nil },
        "Unpacked, no ephemera" =>	{ workflow_status: "Unpacked", has_ephemera: false, ephemera_returned: false, ephemera_okay: nil },
        "Unpacked, with ephemera" =>	{ workflow_status: "Unpacked", has_ephemera: true, ephemera_returned: true, ephemera_okay: true },
        "Unpacked, missing ephemera" =>	{ workflow_status: "Unpacked", has_ephemera: true, ephemera_returned: false, ephemera_okay: false },
      }.each_pair do |context, values|
        context "#{context}" do
	  before(:each) do
	    physical_object.current_workflow_status = values[:workflow_status]
	    physical_object.has_ephemera = values[:has_ephemera]
	    physical_object.ephemera_returned = values[:ephemera_returned]
	    physical_object.save!
	  end
	  specify "sets ephemera_okay to: #{values[:ephemera_okay].nil? ? "nil" : values[:ephemera_okay].to_s}" do
	    expect(physical_object.workflow_statuses.last.ephemera_okay).to eq values[:ephemera_okay]
	  end
	end
      end
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
    specify "workflow_note returns notes" do
      valid_workflow_status.notes = "note text"
      expect(valid_workflow_status.workflow_note).to eq valid_workflow_status.notes
    end
    describe "#past_status?(status_name)" do
      context "with an invalid template" do
        let(:status_name) { "Invalid status" }
        it "raises an error" do
          expect{valid_workflow_status.past_status?(status_name)}.to raise_error RuntimeError
        end
      end
      context "with a current status" do
        let(:status_name) { valid_workflow_status.name }
        it "returns false" do
          expect(valid_workflow_status.past_status?(status_name)).to eq false
        end
      end
      context "with a past status" do
        before(:each) { valid_workflow_status.workflow_status_template = WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).last }
        let(:status_name) { WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).first.name }
        it "returns true" do
          expect(valid_workflow_status.past_status?(status_name)).to eq true
        end
      end
      context "with a future status" do
        before(:each) { valid_workflow_status.workflow_status_template = WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).first }
        let(:status_name) { WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).last.name }
        it "returns false" do
          expect(valid_workflow_status.past_status?(status_name)).to eq false
        end
      end
    end
    describe "#past_or_equal_status?(status_name)" do
      context "with an invalid template" do
        let(:status_name) { "Invalid status" }
        it "raises an error" do
          expect{valid_workflow_status.past_or_equal_status?(status_name)}.to raise_error RuntimeError
        end
      end
      context "with a current status" do
        let(:status_name) { valid_workflow_status.name }
        it "returns true" do
          expect(valid_workflow_status.past_or_equal_status?(status_name)).to eq true
        end
      end
      context "with a past status" do
        before(:each) { valid_workflow_status.workflow_status_template = WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).last }
        let(:status_name) { WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).first.name }
        it "returns true" do
          expect(valid_workflow_status.past_or_equal_status?(status_name)).to eq true
        end
      end
      context "with a future status" do
        before(:each) { valid_workflow_status.workflow_status_template = WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).first }
        let(:status_name) { WorkflowStatusTemplate.where(object_type: "Physical Object").order(:sequence_index).last.name }
        it "returns false" do
          expect(valid_workflow_status.past_or_equal_status?(status_name)).to eq false
        end
      end
    end
  end

  include_examples "has user field" do
    let(:target_object) { valid_workflow_status }
  end

  it_behaves_like "includes XMLExportModule" do
    let(:target_object) { valid_workflow_status }
  end

end
