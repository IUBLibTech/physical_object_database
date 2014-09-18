require 'rails_helper'

describe BinsController do
  render_views
  before(:each) { sign_in }
  let(:batch) { FactoryGirl.create(:batch) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:box) { FactoryGirl.create(:box, bin: bin) }
  let(:unit) { FactoryGirl.create(:unit) }
  let(:boxed_object) { FactoryGirl.create(:physical_object, :cdr, unit: unit, box: box) }
  let(:other_boxed_object) { FactoryGirl.create(:physical_object, :cdr, unit: unit, box: unassigned_box) }
  let(:binned_object) { FactoryGirl.create(:physical_object, :cdr, unit: unit, bin: bin) }
  let(:unassigned_object) { FactoryGirl.create(:physical_object, :cdr, unit: unit) }
  let(:unassigned_box) { FactoryGirl.create(:box) }
  let(:picklist) { FactoryGirl.create(:picklist) }
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

  describe "GET show" do
    before(:each) do
      bin
      box
      binned_object
      other_boxed_object
      boxed_object
      unassigned_object
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
    end
    it "assigns @picklists to picklists dropdown values" do
      
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
      box
      binned_object
      expect{ deletion }.to change(Bin, :count).by(-1)
    end
    it "redirects to the object index" do
      deletion
      expect(response).to redirect_to bins_path
    end
    it "disassociates remaining boxes and physical objects" do
      deletion
      binned_object.reload
      box.reload
      expect(binned_object.bin).to be_nil
      expect(box.bin).to be_nil
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
      bin.reload
      expect(bin.batch).to be_nil
    end
    it "redirects to :back" do
      expect(response).to redirect_to "source_page"
    end
  end
  
  describe "GET show_boxes" do
    context "for an unpacked bin" do
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
    context "for a packed bin" do
      before(:each) do
        bin.current_workflow_status = "Packed"
        bin.save
        get :show_boxes, id: bin.id
      end
      it "flashes packed_status_message" do
        expect(flash[:notice]).to eq Box.packed_status_message
      end
      it "redirect to :show" do
        expect(response).to redirect_to action: :show
      end
    end
  end
 
  describe "PATCH assign_boxes" do
    context "for an unpacked bin" do
      before(:each) do
        patch :assign_boxes, id: bin.id, box_ids: [unassigned_box.id]
      end
      it "assigns boxes to bin" do
        unassigned_box.reload
        expect(unassigned_box.bin).to eq bin
      end
    end
    context "for a packed bin" do
      before(:each) do 
        bin.current_workflow_status = "Packed"
        bin.save
        patch :assign_boxes, id: bin.id, box_ids: [unassigned_box.id]
      end
      it "flashes packed_status_message" do
        expect(flash[:notice]).to eq Box.packed_status_message
      end
      it "redirects to :show" do
        expect(response).to redirect_to action: :show
      end
    end
    it "NOTE: does not check if box is already binned in another bin"
  end

end
