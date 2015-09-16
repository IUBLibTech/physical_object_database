# Units is table with seed data, protected from automated test cleanup
# Manual record deletion is necessary for each test, where applicable
#
describe UnitsController do
  render_views
  before(:each) { sign_in }
  
  let(:unit) { FactoryGirl.create(:unit) }
  let(:valid_unit) { FactoryGirl.build(:unit) }
  let(:invalid_unit) { FactoryGirl.build(:unit, :invalid) }
  
  let(:unit_object) { FactoryGirl.create(:physical_object, :boxable, unit: unit) }

  let(:valid_attributes) { FactoryGirl.attributes_for(:unit) }
  let(:invalid_attributes) { FactoryGirl.attributes_for(:unit, :invalid) }

  describe "GET #index" do
    before(:each) do
      unit
      get :index
    end
    after(:each) { unit.destroy }
    it "assigns all units as @units" do
      expect(assigns(:units)).to include unit 
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    before(:each) { get :show, id: unit.id }
    after(:each) { unit.destroy }
    it "assigns the requested unit as @unit" do
      expect(assigns(:unit)).to eq(unit)
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before(:each) { get :new }
    it "assigns a new unit as @unit" do
      expect(assigns(:unit)).to be_a_new(Unit)
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    before(:each) { get :edit, id: unit.id }
    after(:each) { unit.destroy }
    it "assigns the requested unit as @unit" do
      expect(assigns(:unit)).to eq(unit)
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    let(:post_create) { post :create, unit: create_attributes }
    context "with valid params" do
      let(:create_attributes) { valid_attributes }
      after(:each) { assigns(:unit).destroy }
      it "creates a new Unit" do
        expect { post_create }.to change(Unit, :count).by(1)
      end
      it "assigns a newly created unit as @unit" do
        post_create
        expect(assigns(:unit)).to be_a(Unit)
        expect(assigns(:unit)).to be_persisted
      end
      it "redirects to the created unit" do
        post_create
        expect(response).to redirect_to(assigns(:unit))
      end
    end
    context "with invalid params" do
      let(:create_attributes) { invalid_attributes }
      it "assigns a newly created but unsaved unit as @unit" do
        post_create
        expect(assigns(:unit)).to be_a_new(Unit)
        expect(assigns(:unit)).not_to be_persisted
      end
      it "re-renders the 'new' template" do
        post_create
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:put_update) { put :update, id: unit.id, unit: update_attributes }
    before(:each) { put_update }
    after(:each) { unit.destroy }
    context "with valid params" do
      let(:original_name) { unit.name }
      let(:update_attributes) { { name: original_name + " updated" } }
      it "assigns the requested unit as @unit" do
        expect(assigns(:unit)).to eq(unit)
      end
      it "updates the requested unit" do
        expect(unit.name).to eq original_name
        unit.reload
        expect(unit.name).not_to eq original_name
      end
      it "redirects to the unit" do
        expect(response).to redirect_to(unit)
      end
    end
    context "with invalid params" do
      let(:update_attributes) { { name: "" } }
      it "assigns the unit as @unit" do
        expect(assigns(:unit)).to eq(unit)
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:delete_destroy) { delete :destroy, id: unit.id }
    before(:each) { unit }
    context "with no associated objects: succeeds" do
      it "destroys the requested unit" do
        expect { delete_destroy }.to change(Unit, :count).by(-1)
      end
      it "redirects to the units list" do
        delete_destroy
        expect(response).to redirect_to(units_path)
      end
    end
    context "with an associated object: fails" do
      before(:each) { unit_object }
      after(:each) { unit_object.destroy; unit.destroy }
      it "does NOT destroy the requested unit" do
        expect { delete_destroy }.not_to change(Unit, :count)
      end
      it "renders the :show page" do
        delete_destroy
	expect(response).to render_template :show
      end
      it "renders the physical_objects_table partial" do
        delete_destroy
	expect(response).to render_template partial: 'physical_objects/_physical_objects_table'
      end
      it "flashes a failure warning" do
        delete_destroy
	expect(flash.now[:warning]).to match /not/
      end
      it "sets @show_dependents" do
        delete_destroy
	expect(assigns(:show_dependents)).to eq true
      end
      it "sets @physical_objects" do
        delete_destroy
	expect(assigns(:physical_objects)).to eq [unit_object]
      end
    end
  end

end
