# Machines is table with seed data, protected from automated test cleanup
# Manual record deletion is necessary for each test, where applicable
#
describe MachinesController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
  
  let(:machine) { FactoryGirl.create(:machine) }
  let(:valid_machine) { FactoryGirl.build(:machine) }
  let(:invalid_machine) { FactoryGirl.build(:machine, :invalid) }

  let(:valid_attributes) { FactoryGirl.attributes_for(:machine) }
  let(:invalid_attributes) { FactoryGirl.attributes_for(:machine, :invalid) }

  describe "GET #index" do
    before(:each) do
      machine
      get :index
    end
    after(:each) { machine.destroy }
    it "assigns all machines as @machines" do
      expect(assigns(:machines)).to include machine 
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    before(:each) { get :show, id: machine.id }
    after(:each) { machine.destroy }
    it "assigns the requested machine as @machine" do
      expect(assigns(:machine)).to eq(machine)
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before(:each) { get :new }
    it "assigns a new machine as @machine" do
      expect(assigns(:machine)).to be_a_new(Machine)
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    before(:each) { get :edit, id: machine.id }
    after(:each) { machine.destroy }
    it "assigns the requested machine as @machine" do
      expect(assigns(:machine)).to eq(machine)
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    let(:post_create) { post :create, machine: create_attributes }
    context "with valid params" do
      let(:create_attributes) { valid_attributes }
      after(:each) { assigns(:machine).destroy }
      it "creates a new Machine" do
        expect { post_create }.to change(Machine, :count).by(1)
      end
      it "assigns a newly created machine as @machine" do
        post_create
        expect(assigns(:machine)).to be_a(Machine)
        expect(assigns(:machine)).to be_persisted
      end
      it "redirects to the created machine" do
        post_create
        expect(response).to redirect_to(assigns(:machine))
      end
    end
    context "with invalid params" do
      let(:create_attributes) { invalid_attributes }
      it "assigns a newly created but unsaved machine as @machine" do
        post_create
        expect(assigns(:machine)).to be_a_new(Machine)
        expect(assigns(:machine)).not_to be_persisted
      end
      it "re-renders the 'new' template" do
        post_create
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:put_update) { put :update, id: machine.id, machine: update_attributes }
    before(:each) { put_update }
    after(:each) { machine.destroy }
    context "with valid params" do
      let(:original_serial) { machine.serial }
      let(:update_attributes) { { serial: original_serial + " updated" } }
      it "assigns the requested machine as @machine" do
        expect(assigns(:machine)).to eq(machine)
      end
      it "updates the requested machine" do
        expect(machine.serial).to eq original_serial
        machine.reload
        expect(machine.serial).not_to eq original_serial
      end
      it "redirects to the machine" do
        expect(response).to redirect_to(machine)
      end
    end
    context "with invalid params" do
      let(:update_attributes) { { serial: "" } }
      it "assigns the machine as @machine" do
        expect(assigns(:machine)).to eq(machine)
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:delete_destroy) { delete :destroy, id: machine.id }
    before(:each) { machine }
    it "destroys the requested machine" do
      expect { delete_destroy }.to change(Machine, :count).by(-1)
    end
    it "redirects to the machines list" do
      delete_destroy
      expect(response).to redirect_to(machines_path)
    end
  end

end
