# SignalChains is table with seed data, protected from automated test cleanup
# Manual record deletion is necessary for each test, where applicable
#
describe SignalChainsController do
  render_views
  before(:each) { sign_in }
  
  let(:signal_chain) { FactoryGirl.create(:signal_chain) }
  let(:valid_signal_chain) { FactoryGirl.build(:signal_chain) }
  let(:invalid_signal_chain) { FactoryGirl.build(:signal_chain, :invalid) }

  let(:valid_attributes) { FactoryGirl.attributes_for(:signal_chain) }
  let(:invalid_attributes) { FactoryGirl.attributes_for(:signal_chain, :invalid) }

  describe "GET #index" do
    before(:each) do
      signal_chain
      get :index
    end
    after(:each) { signal_chain.destroy }
    it "assigns all signal_chains as @signal_chains" do
      expect(assigns(:signal_chains)).to include signal_chain 
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    before(:each) { get :show, id: signal_chain.id }
    after(:each) { signal_chain.destroy }
    it "assigns the requested signal_chain as @signal_chain" do
      expect(assigns(:signal_chain)).to eq(signal_chain)
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before(:each) { get :new }
    it "assigns a new signal_chain as @signal_chain" do
      expect(assigns(:signal_chain)).to be_a_new(SignalChain)
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    before(:each) { get :edit, id: signal_chain.id }
    after(:each) { signal_chain.destroy }
    it "assigns the requested signal_chain as @signal_chain" do
      expect(assigns(:signal_chain)).to eq(signal_chain)
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    let(:post_create) { post :create, signal_chain: create_attributes }
    context "with valid params" do
      let(:create_attributes) { valid_attributes }
      after(:each) { assigns(:signal_chain).destroy }
      it "creates a new SignalChain" do
        expect { post_create }.to change(SignalChain, :count).by(1)
      end
      it "assigns a newly created signal_chain as @signal_chain" do
        post_create
        expect(assigns(:signal_chain)).to be_a(SignalChain)
        expect(assigns(:signal_chain)).to be_persisted
      end
      it "redirects to the created signal_chain" do
        post_create
        expect(response).to redirect_to(assigns(:signal_chain))
      end
    end
    context "with invalid params" do
      let(:create_attributes) { invalid_attributes }
      it "assigns a newly created but unsaved signal_chain as @signal_chain" do
        post_create
        expect(assigns(:signal_chain)).to be_a_new(SignalChain)
        expect(assigns(:signal_chain)).not_to be_persisted
      end
      it "re-renders the 'new' template" do
        post_create
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:put_update) { put :update, id: signal_chain.id, signal_chain: update_attributes }
    before(:each) { put_update }
    after(:each) { signal_chain.destroy }
    context "with valid params" do
      let(:original_name) { signal_chain.name }
      let(:update_attributes) { { name: original_name + " updated" } }
      it "assigns the requested signal_chain as @signal_chain" do
        expect(assigns(:signal_chain)).to eq(signal_chain)
      end
      it "updates the requested signal_chain" do
        expect(signal_chain.name).to eq original_name
        signal_chain.reload
        expect(signal_chain.name).not_to eq original_name
      end
      it "redirects to the signal_chain" do
        expect(response).to redirect_to(signal_chain)
      end
    end
    context "with invalid params" do
      let(:update_attributes) { { name: "" } }
      it "assigns the signal_chain as @signal_chain" do
        expect(assigns(:signal_chain)).to eq(signal_chain)
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:delete_destroy) { delete :destroy, id: signal_chain.id }
    before(:each) { signal_chain }
    it "destroys the requested signal_chain" do
      expect { delete_destroy }.to change(SignalChain, :count).by(-1)
    end
    it "redirects to the signal_chains list" do
      delete_destroy
      expect(response).to redirect_to(signal_chains_path)
    end
  end

  describe "#include" do
    pending
  end

  describe "#reorder" do
    pending
  end

end
