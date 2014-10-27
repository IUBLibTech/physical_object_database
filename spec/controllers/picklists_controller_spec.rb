require 'rails_helper'

describe PicklistsController do
  render_views
  before(:each) { sign_in }
  let(:picklist) { FactoryGirl.create(:picklist) }
  let(:valid_picklist) { FactoryGirl.build(:picklist) }
  let(:invalid_picklist) { FactoryGirl.build(:invalid_picklist) }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr, picklist: picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode ) }
  let(:box) { FactoryGirl.create(:box) }
  let(:bin) { FactoryGirl.create(:bin) }

  #no index

  describe "GET show on member" do
    context "html format" do
      before(:each) { get :show, id: picklist.id, format: :html }
      it "assigns the requested picklist to @picklist" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
      include_examples "provides pagination", :physical_objects
    end
    context "csv format" do
      let(:show_csv) { get :show, id: picklist.id, format: :csv }
      it "sends a csv file" do
        expect(controller).to receive(:send_data).with(PhysicalObject.to_csv(picklist.physical_objects, picklist)) { controller.render nothing: true }
        show_csv
      end
      include_examples "does not provide pagination", :physical_objects
    end
    context "xls format" do
      let(:show_xls) { get :show, id: picklist.id, format: :xls }
      it "renders the :show template" do
        skip "test should pass for Excel template, but fails"
        #expect(response).to render_template(:show)
      end
      it "contains the correct Excel file content" do
        skip "TODO: test Excel file content"
      end
      include_examples "does not provide pagination", :physical_objects
    end
  end

  describe "GET new on collection" do
    before(:each) { get :new }
    it "assigns a new object to @picklist" do
      expect(assigns(:picklist)).to be_a_new(Picklist)
    end
    it "renders the :new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET edit on member" do
    before(:each) { get :edit, id: picklist.id }
    it "locates the requested object" do
      expect(assigns(:picklist)).to eq picklist
    end
    it "renders the :edit template" do
      expect(response).to render_template(:edit) 
    end
  end

  describe "POST create on member" do
    context "with valid attributes" do
      let(:creation) { post :create, picklist: valid_picklist.attributes.symbolize_keys }
      it "saves the new physical object in the database" do
        expect{ creation }.to change(Picklist, :count).by(1)
      end
      it "redirects to the picklist specifications" do
        creation
        expect(response).to redirect_to(controller: :picklist_specifications, action: :index) 
      end
    end

    context "with invalid attributes" do
      let(:creation) { post :create, picklist: invalid_picklist.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "does not save the new physical object in the database" do
        expect(invalid_picklist).to be_invalid
        expect{ creation }.not_to change(Picklist, :count)
      end
      it "re-renders the :new template" do
        creation
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT update on member" do
    context "with valid attributes" do
      before(:each) do
        put :update, id: picklist.id, picklist: FactoryGirl.attributes_for(:picklist, name: "Updated Test Picklist")
      end

      it "locates the requested object" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "changes the object's attributes" do
        expect(picklist.name).not_to eq "Updated Test Picklist"
        picklist.reload
        expect(picklist.name).to eq "Updated Test Picklist"
      end
      it "redirects to the picklist specficications index" do
        expect(response).to redirect_to(controller: :picklist_specifications, action: :index) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: picklist.id, picklist: FactoryGirl.attributes_for(:invalid_picklist)
      end

      it "locates the requested object" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "does not change the object's attributes" do
        expect(picklist.description).not_to eq "Invalid picklist description"
        picklist.reload
        expect(picklist.description).not_to eq "Invalid picklist description"
      end
      it "re-renders the :edit template" do
        expect(response).to render_template(:edit)
      end

    end
  end

  describe "DELETE destroy on member" do
    let(:deletion) { delete :destroy, id: picklist.id }
    it "deletes the object" do
      picklist
      expect{ deletion }.to change(Picklist, :count).by(-1)
    end
    it "redirects to the picklist specifications index" do
      deletion
      expect(response).to redirect_to picklist_specifications_path
    end
    it "disassociates physical objects" do
      expect(physical_object.picklist_id).not_to be_nil
      deletion
      physical_object.reload
      expect(physical_object.picklist_id).to be_nil
    end
  end

  describe "GET process_list on collection" do
    it "redirects to index if no picklist set" do
      get :process_list
      expect(response).to redirect_to controller: 'picklist_specifications', action: 'index'
    end
    it "assigns @picklist" do
      get :process_list, picklist: { id: picklist.id }
      expect(assigns(:picklist)).to eq picklist
    end
    it "assigns a @box if passed" do
      get :process_list, picklist: { id: picklist.id }, box_id: box.id
      expect(assigns(:box)).to eq box
    end
    it "assigns a @bin if passed" do
      get :process_list, picklist: { id: picklist.id }, bin_id: bin.id
      expect(assigns(:bin)).to eq bin
    end
    it "renders :process_list" do
      get :process_list, picklist: { id: picklist.id }
      expect(response).to render_template :process_list
    end
  end

  #FIXME: allow assigning to box and bin, together?
  describe "PATCH assign_to_container on collection" do
    let(:assign_arguments) { {po_id: physical_object.id, physical_object: { mdpi_barcode: physical_object.mdpi_barcode, has_ephemera: physical_object.has_ephemera }, bin_id: nil, box_id: nil, bin_barcode: nil, box_barcode: nil} }
    let(:assign_to_container) { patch :assign_to_container, **assign_arguments }
    it "assigns a physical object to a bin by bin_id" do
      assign_arguments[:bin_id] = bin.id 
      assign_to_container
      physical_object.reload
      expect(physical_object.bin).to eq bin
      expect(physical_object.current_workflow_status.name).to eq "Binned"
    end
    it "assigns a physical object to a bin by bin_barcode" do
      bin.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
      bin.save
      assign_arguments[:bin_barcode] = bin.mdpi_barcode 
      assign_to_container
      physical_object.reload
      expect(physical_object.bin).to eq bin
      expect(physical_object.current_workflow_status.name).to eq "Binned"
    end
    it "rejects a 0 for bin_barcode" do
      bin.mdpi_barcode = "0"
      bin.save
      assign_arguments[:bin_barcode] = bin.mdpi_barcode
      assign_to_container
      physical_object.reload
      expect(physical_object.bin).to be_nil
    end
    it "assigns a physical object to a box by box_id" do
      assign_arguments[:box_id] = box.id 
      assign_to_container
      physical_object.reload
      expect(physical_object.box).to eq box
      expect(physical_object.current_workflow_status.name).to eq "Boxed"
    end
    it "assigns a physical object to a box by box_barcode" do
      assign_arguments[:box_barcode] = box.mdpi_barcode
      assign_to_container
      physical_object.reload
      expect(physical_object.box).to eq box
      expect(physical_object.current_workflow_status.name).to eq "Boxed"
    end
    it "rejects a 0 for box_barcode" do
      box.mdpi_barcode = "0"
      box.save
      assign_arguments[:box_barcode] = box.mdpi_barcode
      assign_to_container
      physical_object.reload
      expect(physical_object.box).to be_nil
    end
    it "sets only box when assigning both a bin and box simultaneously" do
      assign_arguments[:bin_id] = bin.id
      assign_arguments[:box_id] = box.id
      assign_to_container
      physical_object.reload
      expect(physical_object.box).not_to be_nil
      expect(physical_object.bin).to be_nil
      expect(physical_object.current_workflow_status.name).to eq "Boxed"
    end
  end

  describe "PATCH remove_from_container on collection" do
    let(:remove_from_container) { patch :remove_from_container, po_id: physical_object.id }
    it "removes the physical object from a bin" do
      physical_object.bin = bin
      physical_object.save
      physical_object.reload
      expect(physical_object.bin).not_to be_nil
      remove_from_container
      physical_object.reload
      expect(physical_object.bin).to be_nil
      expect(physical_object.current_workflow_status.name).to eq "Barcoded"
    end
    it "removes the physical object from a box" do
      physical_object.box = box
      physical_object.save
      physical_object.reload
      expect(physical_object.box).not_to be_nil
      remove_from_container
      physical_object.reload
      expect(physical_object.box).to be_nil
      expect(physical_object.current_workflow_status.name).to eq "Barcoded"
    end
  end

  describe "PATCH container_full on collection" do
    let(:patch_arguments) { {bin_id: nil, box_id: nil, bin_barcode: nil} }
    let(:container_full) { patch :container_full, **patch_arguments }
    context "with box_id and bin_id argument" do
      it "associates bin to box" do
        expect(box.bin).to be_nil
        patch_arguments[:bin_id] = bin.id
        patch_arguments[:box_id] = box.id
        container_full
        box.reload
        expect(box.bin).to eq bin
      end
    end
    context "with box_id and bin_barcode argument" do
      it "associates bin to box" do
        expect(box.bin).to be_nil
        patch_arguments[:bin_barcode] = bin.mdpi_barcode
        patch_arguments[:box_id] = box.id
        container_full
        box.reload
        expect(box.bin).to eq bin
      end
    end
    context "with box_id argument" do
      skip "TODO: no effect when packing box"
    end
    context "with bin_id argument" do
      it "sets bin status to Packed" do
        expect(bin.current_workflow_status.name).not_to eq "Packed"
	patch_arguments[:bin_id] = bin.id
	container_full
	bin.reload
        expect(bin.current_workflow_status.name).to eq "Packed"
      end
    end
    context "with bin_barcode argument" do
      it "sets bin status to Packed" do
        expect(bin.current_workflow_status.name).not_to eq "Packed"
	patch_arguments[:bin_barcode] = bin.mdpi_barcode
	container_full
	bin.reload
        expect(bin.current_workflow_status.name).to eq "Packed"
      end
    end
    context "with no box or bin" do
      it "flashes an error" do
        container_full
	expect(flash[:notice]).to match /Could not find a Bin/
      end
    end
  end

end
