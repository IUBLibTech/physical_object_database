describe Batch do

  let(:batch) { FactoryGirl.create :batch }
  let(:valid_batch) { FactoryGirl.build :batch }
  let(:invalid_batch) { FactoryGirl.build :invalid_batch }
  let(:duplicate) { FactoryGirl.build :batch, identifier: "duplicate" }
  let(:bin) { FactoryGirl.create :bin, batch: batch }
  let(:box) { FactoryGirl.create :box, bin: bin }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }
  let(:open_reel) { FactoryGirl.create :physical_object, :open_reel, :barcoded, bin: bin }
  let(:binned_object) { FactoryGirl.create :physical_object, :barcoded, :binnable, bin: bin }
  let(:other_binned_object) { FactoryGirl.create :physical_object, :barcoded, :binnable, bin: bin }
  let(:boxed_object) { FactoryGirl.create :physical_object, :barcoded, :boxable, box: box }
  let(:other_boxed_object) { FactoryGirl.create :physical_object, :barcoded, :boxable, box: box }

  let!(:later_time) { Time.now.in_time_zone.change(usec: 0) }
  let!(:earlier_time) { later_time - 1000 }

  describe "FactoryGirl" do
    it "provides a valid batch" do
      expect(valid_batch).to be_valid
    end
    it "provides an invalid batch" do
      expect(invalid_batch).not_to be_valid
    end
  end

  include_examples "includes DestinationModule", FactoryGirl.build(:batch)

  describe "has required fields:" do
    it "requires an identifier" do
      expect(valid_batch.identifier).not_to be_blank
      valid_batch.identifier = ""
      expect(valid_batch).to be_invalid
    end
    it "requires a unique identifier" do
      expect(duplicate).to be_valid
      duplicate.identifier = batch.identifier
      expect(duplicate).to be_invalid
    end
  end

  describe "has optional attributes" do
    describe "format" do
      it "can be nil" do
        valid_batch.format = nil
        expect(valid_batch).to be_valid
      end
      it "is automatically set by bin of physical objects" do
        expect(batch.format).to be_nil
        binned_object
        batch.reload
        expect(batch.format).not_to be_nil
        expect(batch.format).to eq bin.format
      end
      it "is automatically set by bin of boxes" do
        expect(batch.format).to be_nil
        boxed_object
        batch.reload
        expect(batch.format).not_to be_nil
        expect(batch.format).to eq box.format
      end
    end
  end

  describe "has relationships:" do
    it "provides a physical object count" do
      expect(batch.physical_objects_count).to eq 0 
    end
    describe "bins" do
      it "has many bins" do
        expect(batch.bins.size).to eq 0
      end
      it "resets bins workflow status to Sealed if destroyed" do
        expect(bin.workflow_status).to eq "Batched"
        batch.destroy
        bin.reload
        expect(bin.workflow_status).to eq "Sealed"
      end
    end
    it "can have workflow statuses" do
      expect(batch.workflow_statuses.size).to be >= 0
    end
    it "has a default workflow status of Created" do
      expect(batch.current_workflow_status).to eq "Created"
    end
  end

  describe "#binned_physical_objects" do
    context "with no bins" do
      it "returns an empty collection" do
        expect(batch.bins).to be_empty
        expect(batch.binned_physical_objects).to be_empty
      end
    end
    context "with empty bins" do
      before(:each) { bin }
      it "returns an empty collection" do
        expect(batch.bins).not_to be_empty
        expect(batch.binned_physical_objects).to be_empty
      end
    end
    context "with directly filled bins" do
      before(:each) { binned_object }
      it "returns the object collection" do
        expect(batch.binned_physical_objects).to eq [binned_object]
      end
    end
    context "with box-filled bins" do
      before(:each) { boxed_object }
      it "returns the object collection" do
        expect(batch.binned_physical_objects).to eq [boxed_object]
      end
    end
  end

  describe "#first_object" do
    it "returns nil if no bins" do
      expect(batch.bins).to be_empty
      expect(batch.first_object).to be_nil
    end
    it "returns nil if no physical objects" do
      bin
      expect(batch.bins).not_to be_empty
      expect(batch.bins.first.physical_objects).to be_empty
      expect(batch.first_object).to be nil
    end
    it "returns first object in first bin" do
      bin
      open_reel
      bin.reload
      expect(bin.boxes).to be_empty
      expect(batch.first_object).to eq open_reel
    end
    it "returns first object in first box in first bin" do
      bin
      box
      physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
      physical_object.box = box
      physical_object.save!
      physical_object.reload
      box.reload
      bin.reload
      expect(batch.first_object).to eq physical_object
    end
  end

  describe "#media_format" do
    it "returns nil if no bins" do
      expect(batch.bins.empty?).to be true
      expect(batch.media_format).to be nil
    end
    it "returns nil if no physical objects" do
      bin
      expect(batch.bins.empty?).to be false
      expect(batch.bins.first.physical_objects).to be_empty
      expect(batch.media_format).to be nil
    end
    it "returns format of first object in first bin" do
      bin
      open_reel
      bin.reload
      expect(bin.boxes).to be_empty
      expect(batch.media_format).to eq open_reel.format
    end
    it "returns format of first object in first box in in first bin" do
      bin
      box
      physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
      physical_object.box = box
      physical_object.save!
      physical_object.reload
      box.reload
      bin.reload
      expect(batch.media_format).to eq physical_object.format
    end
  end
  
  describe "#packed_status?" do
    it "returns false if Created" do
      expect(batch.packed_status?).to eq false
    end
    it "returns true for other status" do
      batch.current_workflow_status = "Assigned"
      expect(batch.packed_status?).to eq true
    end
  end

  describe "#digitization_start" do
    context "on a batch not persisted" do
      it "returns nil" do
        expect(valid_batch.digitization_start).to be_nil
      end
    end
    context "on a batch with no objects" do
      it "returns nil" do
        expect(batch.digitization_start).to be_nil
      end
    end
    context "on a batch with directly binned objects" do
      before(:each) do
        binned_object.digital_start = later_time
        binned_object.save!
        other_binned_object.digital_start = earlier_time
        other_binned_object.save!
      end
      context "asking for the first (implicitly)" do
        it "returns .digital_start of earliest object" do
          expect(batch.digitization_start).not_to be_nil
          expect(batch.digitization_start.in_time_zone.change(usec: 0)).to eq other_binned_object.digital_start.in_time_zone.change(usec: 0)
        end
      end
      context "asking for the last (explicitly)" do
        it "returns .digital_start of latest object" do
          expect(batch.digitization_start(true)).not_to be_nil
          expect(batch.digitization_start(true).in_time_zone.change(usec: 0)).to eq binned_object.digital_start.in_time_zone.change(usec: 0)
        end
      end
    end
    context "on a batch with boxed objects" do
      before(:each) do
        boxed_object.digital_start = later_time
        boxed_object.save!
        other_boxed_object.digital_start = earlier_time
        other_boxed_object.save!
      end
      context "asking for the first (implicitly)" do
        it "returns .digital_start of earliest object" do
          expect(batch.digitization_start).not_to be_nil
          expect(batch.digitization_start.in_time_zone.change(usec: 0)).to eq other_boxed_object.digital_start.in_time_zone.change(usec: 0)
        end
      end
      context "asking for the last (explicitly)" do
        it "returns .digital_start of latest object" do
          expect(batch.digitization_start(true)).not_to be_nil
          expect(batch.digitization_start(true).in_time_zone.change(usec: 0)).to eq boxed_object.digital_start.in_time_zone.change(usec: 0)
        end
      end
    end
  end

  describe "#auto_accept" do
    context "on a batch not persisted" do
      it "returns nil" do
        expect(valid_batch.auto_accept).to be_nil
      end
    end
    context "on a batch with no objects" do
      it "returns nil" do
        expect(batch.auto_accept).to be_nil
      end
    end
    context "on a batch with directly binned objects" do
      before(:each) do
        binned_object.digital_start = later_time
        binned_object.save!
        other_binned_object.digital_start = earlier_time
        other_binned_object.save!
      end
      context "asking for the first (implicitly)" do
        it "returns .digital_start + (auto_accept delay) of earliest object" do
          expect(batch.auto_accept).not_to be_nil
          expect(batch.auto_accept.in_time_zone.change(usec: 0)).to eq other_binned_object.auto_accept.in_time_zone.change(usec: 0)
        end
      end
      context "asking for the last (explicitly)" do
        it "returns .digital_start + (auto_accept delay) of latest object" do
          expect(batch.digitization_start(true)).not_to be_nil
          expect(batch.auto_accept(true).in_time_zone.change(usec: 0)).to eq binned_object.auto_accept.in_time_zone.change(usec: 0)
        end
      end
    end
    context "on a batch with boxed objects" do
      before(:each) do
        boxed_object.digital_start = later_time
        boxed_object.save!
        other_boxed_object.digital_start = earlier_time
        other_boxed_object.save!
      end
      context "asking for the first (implicitly)" do
        it "returns .auto_accept of earliest object" do
          expect(batch.auto_accept).not_to be_nil
          expect(batch.auto_accept.in_time_zone.change(usec: 0)).to eq other_boxed_object.auto_accept.in_time_zone.change(usec: 0)
        end
      end
      context "asking for the last (explicitly)" do
        it "returns .digital_start + (auto_accept delay) of latest object" do
          expect(batch.digitization_start(true)).not_to be_nil
          expect(batch.auto_accept(true).in_time_zone.change(usec: 0)).to eq boxed_object.auto_accept.in_time_zone.change(usec: 0)
        end
      end
    end
  end

  status_list = ["Created", "Assigned", "Shipped", "Interim Storage", "Returned", "Complete"]
  # pass status_list arg here to test previous/next methods
  it_behaves_like "includes WorkflowStatusModule", status_list do
    let(:object) { valid_batch }
    let(:default_status) { "Created" }
    let(:new_status) { "Assigned" }
    let(:valid_status_values) { status_list }
    let(:class_title) { "Batch" }
  end

  describe "::packed_status_message" do
    it "returns a message that the Batch is past Created status" do
      expect(Batch.packed_status_message).to match /This batch cannot have.*bins assigned/
    end
  end

end

