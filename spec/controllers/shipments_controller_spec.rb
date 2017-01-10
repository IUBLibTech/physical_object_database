describe ShipmentsController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:valid_attributes) { FactoryGirl.attributes_for :shipment }
  let(:invalid_attributes) { FactoryGirl.attributes_for :shipment, :invalid }
  let(:shipment) { FactoryGirl.create :shipment }

  describe "GET #index" do
    before(:each) do
      shipment
      get :index
    end
    it "assigns all shipments as @shipments" do
      expect(assigns(:shipments)).to eq([shipment])
    end
    it "renders :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before(:each) do
      get :show, id: shipment.id
    end
    it "assigns the requested shipment as @shipment" do
      expect(assigns(:shipment)).to eq(shipment)
    end
    it "assigns @physical_objects" do
      expect(assigns(:shipment).physical_objects).to eq shipment.physical_objects
    end
    it "assigns @picklists" do
      expect(assigns(:shipment).picklists).to eq shipment.picklists
    end
    it "renders :show view" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before(:each) { get :new }
    it "assigns a new shipment as @shipment" do
      expect(assigns(:shipment)).to be_a_new(Shipment)
    end
    it "renders :new" do
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    before(:each) { get :edit, id: shipment.id }
    it "assigns the requested shipment as @shipment" do
      expect(assigns(:shipment)).to eq(shipment)
    end
    it "renders :edit" do
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:creation) { post :create, shipment: valid_attributes }
      it "creates a new Shipment" do
        expect { creation }.to change(Shipment, :count).by(1)
      end
      it "assigns a newly created shipment as @shipment" do
        creation
        expect(assigns(:shipment)).to be_a(Shipment)
        expect(assigns(:shipment)).to be_persisted
      end
      it "redirects to the created shipment" do
        creation
        expect(response).to redirect_to(Shipment.last)
      end
    end
    context "with invalid params" do
      let(:creation) { post :create, shipment: invalid_attributes }
      it "does not create a new Shipment" do
        expect { creation }.not_to change(Shipment, :count)
      end
      it "assigns a newly created but unsaved shipment as @shipment" do
        creation
        expect(assigns(:shipment)).to be_a_new(Shipment)
        expect(assigns(:shipment)).not_to be_persisted
      end
      it "re-renders the 'new' template" do
        creation
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    before(:each) { put :update, id: shipment.id, shipment: new_attributes }
    context "with valid params" do
      let(:new_attributes) { { description: 'updated description' } }
      it "assigns the requested shipment as @shipment" do
        expect(assigns(:shipment)).to eq(shipment)
      end
      it "updates the requested shipment" do
        shipment.reload
        expect(shipment.description).to eq 'updated description'
      end
      it "redirects to the shipment" do
        expect(response).to redirect_to(shipment)
      end
    end
    context "with invalid params" do
      let(:new_attributes) { { description: 'updated description', identifier: '' } }
      it "assigns the shipment as @shipment" do
        expect(assigns(:shipment)).to eq(shipment)
      end
      it "does not update the requested shipment" do
        shipment.reload
        expect(shipment.description).not_to eq 'updated description'
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:deletion) { delete :destroy, id: shipment.id }
    it "destroys the requested shipment" do
      shipment
      expect { deletion }.to change(Shipment, :count).by(-1)
    end
    it "redirects to the shipments list" do
      deletion
      expect(response).to redirect_to(shipments_url)
    end
  end

  describe "#unload" do
    before(:each) { get :unload, id: shipment.id }
    it "assigns @shipment" do
      expect(assigns(:shipment)).to eq shipment
    end
    it "renders :unload" do
      expect(response).to render_template :unload
    end
  end

  describe "#unload_object" do
    before(:each) { patch :unload_object, id: shipment.id, mdpi_barcode: mdpi_barcode }
    shared_examples "common behaviors" do
      it "assigns the shipment" do
        expect(assigns(:shipment)).to eq shipment
      end
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
      end
    end
    context "with an invalid object:" do
      context "object not found" do
        let(:mdpi_barcode) { 42 }
        it "flashes warning: not found" do
          expect(assigns[:po]).to be_nil
          expect(flash[:warning]).to match /^No.*found.?$/
        end
        include_examples 'common behaviors'
      end
      context "object not in shipment" do
        let(:external_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }
        let(:mdpi_barcode) { external_object.mdpi_barcode }
        it "flashes warning: not in shipment" do
          expect(flash[:warning]).to match /not.*ship/i
        end
        include_examples 'common behaviors'
      end
      context "object already unloaded" do
        let(:picklist) { FactoryGirl.create :picklist }
        let(:unloaded_object) { FactoryGirl.create :physical_object, :cdr, :barcoded, shipment: shipment, picklist: picklist }
        let(:mdpi_barcode) { unloaded_object.mdpi_barcode }
        it "flashes notice: already unloaded" do
          expect(flash[:notice]).to match /already.*unloaded/
        end
        include_examples 'common behaviors'
      end
    end
    context "with a valid object" do
      let(:valid_object) { FactoryGirl.create :physical_object, :cdr, :barcoded, shipment: shipment }
      let(:mdpi_barcode) { valid_object.mdpi_barcode }
      include_examples 'common behaviors'
      it 'assigns @po' do
        expect(assigns(:po)).to eq valid_object
      end
      it "assigns the object to a picklist" do
        expect(valid_object.picklist).to be_nil
        valid_object.reload
        expect(valid_object.picklist).not_to be_nil
      end
      it "flashes notice: assigned to picklist" do
        expect(flash[:notice]).to match /has been assigned.*picklist/
      end
    end
  end

  describe "#reload" do
    before(:each) { get :reload, id: shipment.id }
    it "assigns @shipment" do
      expect(assigns(:shipment)).to eq shipment
    end
    it "renders :reload" do
      expect(response).to render_template :reload
    end
  end

  describe "#reload_object" do
    before(:each) { patch :reload_object, id: shipment.id, mdpi_barcode: mdpi_barcode }
    shared_examples "common behaviors" do
      it "assigns the shipment" do
        expect(assigns(:shipment)).to eq shipment
      end
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
      end
    end
    context "with an invalid object:" do
      context "object not found" do
        let(:mdpi_barcode) { 42 }
        it "flashes warning: not found" do
          expect(assigns[:po]).to be_nil
          expect(flash[:warning]).to match /^No.*found.?$/
        end
        include_examples 'common behaviors'
      end
      context "object not in shipment" do
        let(:external_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }
        let(:mdpi_barcode) { external_object.mdpi_barcode }
        it "flashes warning: not in shipment" do
          expect(flash[:warning]).to match /not.*ship/i
        end
        include_examples 'common behaviors'
      end
      context "object already repacked" do
        let(:picklist) { FactoryGirl.create :picklist }
        let(:reloaded_object) { FactoryGirl.create :physical_object, :cdr, :barcoded, shipment: shipment, current_workflow_status: 'Returned to Unit' }
        let(:mdpi_barcode) { reloaded_object.mdpi_barcode }
        it "flashes notice: already repacked" do
          expect(flash[:notice]).to match /already.*repacked/
        end
        include_examples 'common behaviors'
      end
      context "object has invalid workflow status" do
        let(:picklist) { FactoryGirl.create :picklist }
        let(:invalid_object) { FactoryGirl.create :physical_object, :cdr, :barcoded, shipment: shipment, current_workflow_status: 'Unassigned' }
        let(:mdpi_barcode) { invalid_object.mdpi_barcode }
        it "flashes notice: invalid workflow status" do
          expect(flash[:warning]).to match /cannot.*repack/
        end
        include_examples 'common behaviors'
      end
    end
    context "with a valid object" do
      let(:valid_object) { FactoryGirl.create :physical_object, :cdr, :barcoded, shipment: shipment, current_workflow_status: 'Unpacked' }
      let(:mdpi_barcode) { valid_object.mdpi_barcode }
      include_examples 'common behaviors'
      it 'assigns @po' do
        expect(assigns(:po)).to eq valid_object
      end
      it "updated the object's workflow status" do
        expect(valid_object.workflow_status).not_to eq 'Returned to Unit'
        valid_object.reload
        expect(valid_object.workflow_status).to eq 'Returned to Unit'
      end
      it "flashes notice: assigned to picklist" do
        expect(flash[:notice]).to match /workflow status updated/
      end
    end
  end

  describe "GET #shipments_list" do
    before(:each) do
      get :shipments_list
    end
    it "renders :shipments_list partial" do
      expect(response).to render_template('_shipments_list')
    end
  end

end
