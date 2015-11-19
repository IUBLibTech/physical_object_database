require 'rails_helper'

describe BinsController do
  render_views
  before(:each) { 
    sign_in 
    request.env['HTTP_REFERER'] = "Foo"
  }
  let(:batch) { FactoryGirl.create(:batch) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:sealed) {FactoryGirl.create(:bin, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, identifier:"UNIQUE!", current_workflow_status: "Sealed")} 
  let(:box) { FactoryGirl.create(:box, bin: bin) }
  let(:boxed_object) { FactoryGirl.create(:physical_object, :barcoded, :boxable, box: box) }
  let(:other_boxed_object) { FactoryGirl.create(:physical_object, :barcoded, :boxable, box: unassigned_box) }
  let(:binned_object) { FactoryGirl.create(:physical_object, :barcoded, :binnable, bin: bin) }
  let(:unassigned_object) { FactoryGirl.create(:physical_object, :boxable) }
  let(:unassigned_box) { FactoryGirl.create(:box) }
  let(:picklist) { FactoryGirl.create(:picklist) }
  let!(:complete) { FactoryGirl.create(:picklist, name: 'complete', complete: true)}
  let(:valid_bin) { FactoryGirl.build(:bin) }
  let(:invalid_bin) { FactoryGirl.build(:invalid_bin) }

  describe "FactoryGirl creation" do
    specify "makes a valid bin" do
      expect(valid_bin).to be_valid
      expect(bin).to be_valid
    end
    specify "makes an invalid bin" do
      expect(invalid_bin).to be_invalid
    end
  end

  describe "GET index" do
    context "basic functions" do
      before(:each) do
        bin.save
        box.save
        unassigned_box.save
        get :index
      end
      it "populates an array of objects" do
        expect(assigns(:bins)).to eq [bin]
      end
      it "populates unassigned boxes to @boxes" do
        expect(assigns(:boxes)).to eq [unassigned_box]
      end
      it "renders the :index view" do
        expect(response).to render_template(:index)
      end
    end
    describe "workflow status filter" do
      before(:each) do
        bin; sealed
        get :index, workflow_status: workflow_status
      end
      context "with no value set" do
        let(:workflow_status) { nil }
        it "returns all bins" do
          expect(assigns(:bins).sort).to eq [bin, sealed].sort
        end
      end
      context "with a matching value set" do
        let(:workflow_status) { sealed.workflow_status }
        it "returns matching bins" do
          expect(assigns(:bins)).to eq [sealed]
        end
      end
      context "with a non-matching value set" do
        let(:workflow_status) { "non-matching value" }
        it "returns no bins" do
          expect(assigns(:bins)).to be_empty
        end
      end
    end
    describe "format filter" do
      let!(:bin_of_objects) { FactoryGirl.create(:bin, identifier: "bin of objects") }
      let!(:bin_of_boxes) { FactoryGirl.create(:bin, identifier: "bin of boxes") }
      let!(:binned_box) { FactoryGirl.create(:box, bin: bin_of_boxes) }
      let!(:box_format_object) { FactoryGirl.create(:physical_object, :barcoded, :boxable, box: binned_box) }
      let!(:bin_format_object) { FactoryGirl.create(:physical_object, :barcoded, :binnable, bin: bin_of_objects) }
      before(:each) do
        get :index, format: format
      end
      context "with no value set" do
        let(:format) { nil }
        it "returns all bins" do
          expect(assigns(:bins).sort).to eq [bin_of_objects, bin_of_boxes].sort
        end
      end
      context "with a matching binned object value set" do
        let(:format) { bin_of_objects.format }
        it "returns matching bins" do
          expect(assigns(:bins)).to eq [bin_of_objects]
        end
      end
      context "with a matching boxed object value set" do
        let(:format) { bin_of_boxes.format }
        it "returns matching bins" do
          expect(assigns(:bins)).to eq [bin_of_boxes]
        end
      end
      context "with a non-matching value set" do
        let(:format) { "non-matching value" }
        it "returns no bins" do
          expect(assigns(:bins)).to be_empty
        end
      end
    end
  end

  describe "GET show" do
    before(:each) do
      bin
      box
      #binned_object
      other_boxed_object
      boxed_object
      unassigned_object
      picklist
      get :show, id: bin.id
    end

    it "assigns the requested object to @bin" do
      expect(assigns(:bin)).to eq bin
    end
    it "assigns boxes to @boxes" do
      expect(assigns(:boxes)).to eq [box]
    end
    describe "assigns contained physical objects to @physical_objects" do
      it "assigns boxed objects (only)" do
        expect(assigns(:physical_objects)).to eq [boxed_object]
      end
      include_examples "provides pagination", :physical_objects
    end
    it "assigns @picklists to picklists dropdown values" do
      expect(assigns(:picklists)).to eq [[picklist.name, picklist.id]]
    end
    it "renders the :show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET new" do
    before(:each) { batch; get :new }
    it "assigns a new object to @bin" do
      expect(assigns(:bin)).to be_a_new(Bin)
    end
    it "assigns batches values list to @batches" do
      expect(assigns(:batches)).to eq [[batch.identifier, batch.id]]
    end
    it "renders the :new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET edit" do
    before(:each) { bin.batch = batch; bin.save; get :edit, id: bin.id }
    it "locates the requested object" do
      expect(assigns(:bin)).to eq bin
    end
    it "assigns batches values list to @batches" do
      expect(assigns(:batches)).to eq [[batch.identifier, batch.id]]
    end
    it "assigns bin's batch to @batch" do
      expect(assigns(:batch)).to eq batch
    end
    it "renders the :edit template" do
      expect(response).to render_template(:edit) 
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, bin: valid_bin.attributes.symbolize_keys }
      it "saves the new object in the database" do
        expect{ creation }.to change(Bin, :count).by(1)
      end
      it "redirects to the objects index" do
        creation
        expect(response).to redirect_to(controller: :bins, action: :index) 
      end
    end

    context "with invalid attributes" do
      let(:creation) { post :create, bin: invalid_bin.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "does not save the new physical object in the database" do
        bin
        expect{ creation }.not_to change(Bin, :count)
      end
      it "re-renders the :new template" do
        creation
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT update" do
    context "with valid attributes" do
      before(:each) do
        put :update, id: bin.id, bin: FactoryGirl.attributes_for(:bin, identifier: "Updated Test Bin")
      end
      it "locates the requested object" do
        expect(assigns(:bin)).to eq bin
      end
      it "changes the object's attributes" do
        expect(bin.identifier).not_to eq "Updated Test Bin"
        bin.reload
        expect(bin.identifier).to eq "Updated Test Bin"
      end
      it "redirects to the updated object" do
        expect(response).to redirect_to(action: :show) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: bin.id, bin: FactoryGirl.attributes_for(:invalid_bin)
      end

      it "locates the requested object" do
        expect(assigns(:bin)).to eq bin
      end
      it "does not change the object's attributes" do
        expect(bin.identifier).to eq "Test Bin"
        bin.reload
        expect(bin.identifier).to eq "Test Bin"
      end
      it "re-renders the :edit template" do
        expect(response).to render_template(:edit)
      end

    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: bin.id }
    it "deletes the object" do
      bin
      expect{ deletion }.to change(Bin, :count).by(-1)
    end
    it "redirects to the object index" do
      deletion
      expect(response).to redirect_to bins_path
    end
    it "disassociates remaining boxes" do
      box
      deletion
      box.reload
      expect(box.bin).to be_nil
    end
    it "disassociates remaining physical objects" do
      binned_object
      deletion
      binned_object.reload
      expect(binned_object.bin).to be_nil
    end
    it "resets remaining physical objects workflow status when destroyed" do
      expect(binned_object.workflow_status).to eq "Binned"
      deletion
      binned_object.reload
      expect(binned_object.workflow_status).not_to eq "Binned"
    end
  end

  describe "POST add_barcode_item" do
    skip "FIXME: deprecated?"
  end

  describe "POST unbatch" do
    before(:each) do
      bin.batch = batch
      bin.save
      request.env["HTTP_REFERER"] = "source_page"
      post :unbatch, id: bin.id
    end
    it "removes the batch association from the bin" do
      expect(bin.batch).not_to be_nil
      bin.reload
      expect(bin.batch).to be_nil
    end
    it "updates the bin workflow status" do
      expect(bin.current_workflow_status).to eq "Batched"
      bin.reload
      expect(bin.current_workflow_status).not_to eq "Batched"
    end
    it "redirects to :back" do
      expect(response).to redirect_to "source_page"
    end
  end
  
  describe "GET show_boxes" do
    context "for an unsealed bin" do
      before(:each) do 
        box.bin = nil
        box.save
        get :show_boxes, id: bin.id
      end
      it "assigns unassigned boxes to @boxes" do
        expect(assigns(:boxes)).to eq [box]
      end
      it "renders :show_boxes" do
        expect(response).to render_template :show_boxes
      end
    end
    context "for a sealed bin" do
      before(:each) do
        bin.current_workflow_status = "Sealed"
        bin.save
        get :show_boxes, id: bin.id
      end
      it "flashes warning of packed_status_message" do
        expect(flash[:warning]).to eq Bin.packed_status_message
      end
      it "redirects to :show" do
        expect(response).to redirect_to action: :show
      end
    end
    context "for a bin with physical objects" do
      before(:each) do
        binned_object
        get :show_boxes, id: bin.id
      end
      it "flashes a warning of invalid_box_assignment_message" do
        expect(flash[:warning]).to eq Bin.invalid_box_assignment_message
      end
      it "redirects to :show" do
        expect(response).to redirect_to action: :show
      end
    end
  end

  describe "GET workflow_history" do
    before(:each) { get :workflow_history, id: bin.id }
    it "assigns the requested bin to @bin" do
      expect(assigns(:bin)).to eq bin
    end
    it "assigns the worfklow history to @workflow_statuses" do
      expect(assigns(:workflow_statuses)).to eq bin.workflow_statuses
    end
    it "renders the :workflow_history template" do
      expect(response).to render_template(:workflow_history)
    end
  end
 
  describe "PATCH assign_boxes" do
    context "for an unsealed bin" do
      before(:each) do
        patch :assign_boxes, id: bin.id, box_ids: [unassigned_box.id]
      end
      it "assigns boxes to bin" do
        unassigned_box.reload
        expect(unassigned_box.bin).to eq bin
      end
    end
    context "for a sealed bin" do
      before(:each) do 
        bin.current_workflow_status = "Sealed"
        bin.save
        patch :assign_boxes, id: bin.id, box_ids: [unassigned_box.id]
      end
      it "flashes warning of packed_status_message" do
        expect(flash[:warning]).to eq Bin.packed_status_message
      end
      it "redirects to :show" do
        expect(response).to redirect_to action: :show
      end
    end
    context "for a bin with physical objects" do
      before(:each) do
        binned_object
        patch :assign_boxes, id: bin.id, box_ids: [unassigned_box.id]
      end
      it "flashes warning of invalid_box_assignment_message" do
        expect(flash[:warning]).to eq Bin.invalid_box_assignment_message
      end
      it "redirects to :show" do
        expect(response).to redirect_to action: :show
      end
    end
    it "NOTE: does not check if box is already binned in another bin"
  end

  describe "Patch seal Bin" do
    let(:sealed) {FactoryGirl.create(:bin, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, current_workflow_status: "Sealed")} 
    context "with a sealable Bin" do
      before(:each) do
        patch :seal, id: bin.id
      end
      it "it seals the bin" do
        bin.reload
        expect(bin.current_workflow_status).to eq "Sealed"
      end
    end
    context "with an unsealable bin" do
      before(:each) do
        patch :seal, id: sealed.id
      end
      it "warns user" do
        expect(flash[:warning]).to start_with("Cannot Seal Bin")
      end
    end
  end

  describe "POST unseal" do
    before(:each) { request.env["HTTP_REFERER"] = "source_page" }
    context "on an unsealed (Created) bin" do
      before(:each) do
        post :unseal, id: bin.id
      end
      it "flashes a notification that the bin was already unsealed" do
        expect(flash[:notice]).to match /already unsealed/
      end
      it "redirects to bin_path" do
        expect(response).to redirect_to bin_path
      end
    end
    context "on a Sealed bin" do
      before(:each) do
        bin.current_workflow_status = "Sealed"
        bin.save
        post :unseal, id: bin.id
      end
      it "sets the current workflow status to Created" do
        expect(bin.current_workflow_status).to eq "Sealed"
        bin.reload
        expect(bin.current_workflow_status).to eq "Created"
      end
      it "flashes a notification that the bin was successfully unsealed" do
        expect(flash[:notice]).to match /success/
      end
      it "redirects to bin_path" do
       expect(response).to redirect_to bin_path
      end
    end
    context "on a Batched bin" do
      before(:each) do
        bin.batch = batch
        bin.save
        post :unseal, id: bin.id
      end
      it "does not change the workflow status" do
        expect(bin.current_workflow_status).to eq "Batched"
        bin.reload
        expect(bin.current_workflow_status).to eq "Batched"
      end
      it "flashes a notification that the bin must be unbatched " do
        expect(flash[:notice]).to match /must be unbatched/
      end
      it "redirects to :back" do
        expect(response).to redirect_to bin_path
      end
    end
  end

end
