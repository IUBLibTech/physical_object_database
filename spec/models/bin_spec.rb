describe Bin do

  let(:batch) {FactoryGirl.create :batch }
  let(:pl) {}
  let(:bin) { FactoryGirl.create :bin, batch: batch }
  let(:film_bin) { FactoryGirl.create :bin, format: 'Film' }
  let(:box) { FactoryGirl.create :box, bin: bin }
  let(:valid_bin) { FactoryGirl.build :bin }
  let(:invalid_bin) { FactoryGirl.build :bin, :invalid }
  let(:valid_batch) { FactoryGirl.build :batch }
  let(:binned_object) { FactoryGirl.create :physical_object, :barcoded, :binnable, bin: bin }
  let(:boxed_object) { FactoryGirl.create :physical_object, :barcoded, :boxable, box: box }

  describe "FactoryGirl creation" do
    specify "makes a valid bin" do
      expect(valid_bin).to be_valid
      expect(bin).to be_valid
    end
    specify "makes an invalid bin" do
      expect(invalid_bin).to be_invalid
    end
  end

  include_examples "includes DestinationModule", FactoryGirl.build(:bin)

  describe "has required fields:" do
    it "identifier" do
      valid_bin.identifier = nil
      expect(valid_bin).not_to be_valid
    end
    it "identifier unique" do
      bin
      expect(valid_bin).not_to be_valid
      valid_bin.identifier = bin.identifier + "_different"
      expect(valid_bin).to be_valid
    end
    it "mdpi_barcode by mdpi_barcode validation" do
      valid_bin.mdpi_barcode = invalid_mdpi_barcode
      expect(valid_bin).not_to be_valid
    end
  end
  
  describe "has optional fields" do
    specify "average_duration" do
      valid_bin.average_duration = nil
      expect(valid_bin).to be_valid
    end
    it "description" do
      valid_bin.description = nil
      expect(valid_bin).to be_valid
    end
    describe "format" do
      it "can be nil" do
        valid_bin.format = nil
        expect(valid_bin).to be_valid
      end
      it "is automatically set by contained physical object" do
        expect(bin.format).to be_blank
        binned_object
        bin.reload
        expect(bin.format).not_to be_blank
        expect(bin.format).to eq binned_object.format
      end
      it "is automatically set by contained box" do
        expect(bin.format).to be_blank
        boxed_object
        bin.reload
        expect(bin.format).not_to be_blank
        expect(bin.format).to eq box.format
      end
    end
    describe "physical location" do
      it "can be blank" do
        valid_bin.physical_location = ''
        expect(valid_bin).to be_valid
      end
      it "cannot be nil" do
        valid_bin.physical_location = nil
        expect(valid_bin).not_to be_valid
      end
      it "must be a valid value from list" do
        valid_bin.physical_location = "invalid value"
        expect(valid_bin).not_to be_valid
      end
      it "is set as a default value" do
        valid_bin.physical_location = nil
        valid_bin.default_values
        expect(valid_bin.physical_location).not_to be_nil
      end
    end
  end

  describe "has relationships:" do
    it "can belong to a batch" do
      binned_object
      expect(batch.bins.where(id: bin.id).first).to eq(bin)
      expect(bin.batch).to eq batch
      bin.batch = nil
      bin.save
      expect(bin.batch).to eq nil
      expect(batch.bins.where(id: bin.id).first).to be_nil
    end
    it "can belong to a batch with unspecified format" do
      valid_batch.format = nil
      valid_bin.format = TechnicalMetadatumModule.bin_formats.first
      valid_bin.batch = valid_batch
      expect(valid_bin).to be_valid
    end
    it "can belong to a batch with matching format" do
      valid_batch.format = TechnicalMetadatumModule.bin_formats.first
      valid_bin.format = TechnicalMetadatumModule.bin_formats.first
      valid_bin.batch = valid_batch
      expect(valid_bin).to be_valid
    end
    it "cannot belong to a format-specific batch if self.format is blank" do
      valid_batch.format = TechnicalMetadatumModule.bin_formats.first
      valid_bin.format = ""
      valid_bin.batch = valid_batch
      expect(valid_bin).not_to be_valid
    end
    it "cannot belong to a batch with mismatched format" do
      valid_batch.format = TechnicalMetadatumModule.bin_formats.first
      valid_bin.format = TechnicalMetadatumModule.bin_formats.last
      valid_bin.batch = valid_batch
      expect(valid_bin).not_to be_valid
    end
    it "can belong to a picklist specification" do
      expect(bin.picklist_specification).to be_nil
    end
    it "can belong to a spreadsheet" do
      expect(bin.spreadsheet).to be_nil
    end
    it "has many physical objects" do
      expect(bin.physical_objects.size).to eq 0
    end
    it "updates physical objects workflow status when destroyed" do
      expect(binned_object.workflow_status).to eq "Binned"
      bin.destroy
      binned_object.reload
      expect(binned_object.workflow_status).not_to eq "Binned"
    end
    it "has many boxed_physical_objects" do
      expect(bin.boxed_physical_objects.size).to eq 0
    end
    it "has many boxes" do
      expect(bin.boxes.size).to eq 0
    end
    it "has many workflow statuses" do
      expect(bin.workflow_statuses.size).to be >= 0
    end
    it "has many condition statuses" do
      expect(bin.condition_statuses.size).to be >= 0
    end
    
  end

  describe "provides virtual attributes:" do
    it "provides a spreadsheet descriptor" do
      expect(bin.identifier).to eq(bin.spreadsheet_descriptor)
    end
    it "provides a physical object count" do
      expect(bin.physical_objects_count).to eq 0 
    end
    describe "#packed_status?" do
      ["Sealed", "Batched"].each do |status|
        it "returns true if in #{status} status" do
	  bin.current_workflow_status = status
          expect(bin.packed_status?).to eq true
        end
      end
      it "returns false if not in Sealed status" do
        bin.current_workflow_status = "Created"
        expect(bin.packed_status?).to eq false
      end
    end
    describe "#display_workflow_status" do
      it "returns current_workflow_status" do
        expect(bin.display_workflow_status).to match /^#{bin.current_workflow_status}/
      end
      specify "when Batched, also display Batch status (if not Created)" do
        batch.current_workflow_status = "Shipped"
        bin.batch = batch
	expect(bin.display_workflow_status).to match />>/
	expect(bin.display_workflow_status).to match /Shipped$/
      end
      specify "when Batched, surpress Batch status if Created" do
        batch.current_workflow_status = "Created"
	bin.batch = batch
	expect(bin.display_workflow_status).not_to match />>/
	expect(bin.display_workflow_status).not_to match /Created$/
      end
      specify "when Batched, display (No batch assigned) if no Batch assigned" do
        bin.workflow_status = "Batched"
        bin.batch = nil
        expect(bin.display_workflow_status).to match /No batch assigned/
      end
    end
    describe "#inferred_workflow_status" do
      ["Created", "Sealed"].each do |status|
        it "returns Batched if #{status}, and associated to a Batch" do
          bin.current_workflow_status = status
	  bin.batch = batch
	  expect(bin.inferred_workflow_status).to eq "Batched"
        end
      end
      it "returns Sealed if Batched, and not associated to a Batch" do
        bin.current_workflow_status = "Batched"
	bin.batch = nil
	expect(bin.inferred_workflow_status).to eq "Sealed"
      end
      ["Created", "Returned to Staging Area", "Unpacked"].each do |status|
        it "returns #{status} unchanged" do
	  bin.batch = nil
	  bin.current_workflow_status = status
	  expect(bin.inferred_workflow_status).to eq status
	end
      end
    end
  end
  describe "#contained_physical_objects" do
    it "returns empty collection if no physical objects" do
      expect(bin.physical_objects).to be_empty
      expect(bin.boxed_physical_objects).to be_empty
      expect(bin.contained_physical_objects).to be_empty
    end
    it "returns directly contained physical objects" do
      binned_object
      expect(bin.contained_physical_objects).to eq [binned_object]
    end
    it "returns boxed physical objects" do
      boxed_object
      expect(bin.contained_physical_objects).to eq [boxed_object]
    end
  end
  describe "#first_object" do
    it "returns nil if no physical objects" do
      expect(bin.physical_objects).to be_empty
      expect(bin.first_object).to be nil
    end
    it "returns first object if present" do
      binned_object
      expect(bin.first_object).to eq binned_object
    end
    it "returns first object in first box in first bin" do
      boxed_object
      expect(bin.first_object).to eq boxed_object
    end
  end
  describe "#media_format" do
    it "returns nil if no physical objects" do
      expect(bin.physical_objects).to be_empty
      expect(bin.media_format).to be nil
    end
    it "returns first object format if present" do
      binned_object
      expect(bin.media_format).to eq binned_object.format
    end
    it "returns first object format in first box in first bin" do
      boxed_object
      expect(bin.media_format).to eq boxed_object.format
    end
  end
  describe "#set_container_format" do
    context "in a batch" do
      before(:each) do
        valid_bin.format = "CD-R"
        valid_bin.batch = batch
      end
      let(:contained) { valid_bin }
      let(:container) { batch }
      include_examples "nil and blank format cases"
    end
  end
  describe "::packed_status_message" do
    it "returns a message that the Bin is in Sealed status" do
      expect(Bin.packed_status_message).to match /This bin has been marked as sealed/
    end
  end
  describe "::invalid_box_assignment_message" do
    it "returns a message that the Bin contains physical objects" do
      expect(Bin.invalid_box_assignment_message).to match /This bin contains physical objects/
    end
  end

  # it_behaves_like "includes ConditionStatusModule:"
  describe "includes ConditionStatusModule:" do
    let(:condition_status) { FactoryGirl.create(:condition_status, :bin, bin: bin) }
    let(:target_object) { bin }
    let(:class_title) { "Bin" }

    skip "No Condition Statues have been defined for Bins"
  end

  status_list = ["Created", "Sealed", "Batched", "Returned to Staging Area", "Unpacked"]
  # pass status_list arg here to test previous/next methods
  it_behaves_like "includes WorkflowStatusModule" do
    let(:object) { valid_bin }
    let(:default_status) { "Created" }
    let(:new_status) { "Sealed" }
    let(:valid_status_values) { status_list } 
    let(:class_title) { "Bin" }
  end

  describe ".available_bins scope" do
    let!(:batched_bin) { bin }
    let!(:created_bin) { FactoryGirl.create :bin, identifier: 'created' }
    let!(:sealed_bin) { FactoryGirl.create :bin, identifier: 'sealed' }
    before(:each) do
      sealed_bin.current_workflow_status = "Sealed"
      sealed_bin.save!
      expect(sealed_bin.workflow_status).to eq "Sealed"
    end
    it "returns only bins without batches" do
      expect(Bin.available_bins.sort).to eq [created_bin, sealed_bin].sort
    end
  end

  describe "#post_to_filmdb" do
    before(:each) do
      stub_request(:get, /sycamore/).
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: "stubbed response", headers: {})
      stub_request(:post, /sycamore/).
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: "stubbed response", headers: {})
    end
    context "for non-film bins" do
      it "returns nil" do
        expect(bin.format).not_to eq 'Film'
        expect(bin.post_to_filmdb).to be_nil
      end
    end
    context "for film bins" do
      it "connects to FilmDB" do
        expect(film_bin.format).to eq 'Film'
        expect(film_bin.post_to_filmdb.body).to eq 'stubbed response'
      end
    end
  end

end

