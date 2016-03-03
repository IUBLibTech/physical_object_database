describe SignalChainsController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
 
  let(:formats) { ['CD-R'] } 
  let(:signal_chain) { FactoryGirl.create(:signal_chain, :with_formats, formats: formats) }
  let(:valid_signal_chain) { FactoryGirl.build(:signal_chain, :with_formats, formats: formats) }
  let(:invalid_signal_chain) { FactoryGirl.build(:signal_chain, :invalid, :with_formats, formats: formats) }

  let(:valid_attributes) { FactoryGirl.attributes_for(:signal_chain) }
  let(:invalid_attributes) { FactoryGirl.attributes_for(:signal_chain, :invalid) }

  describe "GET #index" do
    before(:each) do
      signal_chain
      get :index
    end
    it "assigns all signal_chains as @signal_chains" do
      expect(assigns(:signal_chains)).to include signal_chain 
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    before(:each) { get :show, id: signal_chain.id }
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
    before(:each) { signal_chain }
    let(:delete_destroy) { delete :destroy, id: signal_chain.id }
    context "when successful" do
      it "destroys the requested signal_chain" do
        expect { delete_destroy }.to change(SignalChain, :count).by(-1)
      end
      it "redirects to the signal_chains list" do
        delete_destroy
        expect(response).to redirect_to(signal_chains_path)
      end
    end
    context "when failed" do
      before(:each) { FactoryGirl.create :digital_file_provenance, signal_chain: signal_chain }
      it "does not destroy the signal_chain" do
        expect{ delete_destroy }.not_to change(SignalChain, :count)
      end
      it "flashes a warning" do
        delete_destroy
        expect(flash.now[:warning]).to match /not.*deleted/i
      end
      it "renders :show" do
        delete_destroy
        expect(response).to render_template :show
      end
    end
  end

  describe "#include" do
    let!(:machine) { FactoryGirl.create(:machine, :with_formats, formats: formats) }
    context "when successful" do
      before(:each) do
        put :include, id: signal_chain.id, machine_id: machine.id, position: signal_chain.processing_steps.size + 1
      end
      it "includes the machine" do
        expect(signal_chain.processing_steps).to be_empty
        signal_chain.reload
        expect(signal_chain.processing_steps[signal_chain.processing_steps.size - 1].machine_id).to eq machine.id
      end
      it "flashes success notice" do
        expect(flash[:notice]).to match /success/
      end
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
      end
    end
    context "when failed" do
      before(:each) do
        put :include, id: signal_chain.id, machine_id: machine.id, position: 0
      end
      it "flashes error warning" do
        expect(flash[:warning]).to match /error/i
      end
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
      end
    end
  end

  describe "PATCH #reorder" do
    let!(:step1) { FactoryGirl.create :processing_step, :with_formats, signal_chain: signal_chain, position: 1, formats: formats }
    let!(:step2) { FactoryGirl.create :processing_step, :with_formats, signal_chain: signal_chain, position: 2, formats: formats }
    before(:each) do
      patch :reorder, id: signal_chain.id, reorder_submission: reorder_submission
    end
    context "with no changes submitted" do
      let(:reorder_submission) { "" }
      it "flashes an inaction notice" do
        expect(flash[:notice]).to match /no change/i
      end
      it "redirects to :back" do
        expect(response).to redirect_to "source_page"
      end
    end
    context "with changes submitted" do
      let(:reorder_submission) { "#{step2.id},#{step1.id}" }
      it "reorders processing_steps" do
        expect(step1.position).to eq 1
        expect(step2.position).to eq 2
        step1.reload
        step2.reload
        expect(step1.position).to eq 2
        expect(step2.position).to eq 1
      end
      it "redirects to back" do
        expect(response).to redirect_to "source_page"
      end
    end
  end

  describe "#ajax_show" do
    context "with a valid id" do
      before(:each) { get :ajax_show, id: signal_chain.id }
      it "assigns @signal_chain" do
        expect(assigns(:signal_chain)).to eq signal_chain
      end
      it "renders partial: 'ajax_show_signal_chain'" do
        expect(response).to render_template partial: '_ajax_show_signal_chain'
      end
    end
    context "with an invalid id" do
      before(:each) { get :ajax_show, id: 'invalid id' }
      it "renders partial: 'ajax_show_signal_chain'" do
        expect(response).to render_template partial: '_ajax_show_signal_chain'
      end
    end
  end

end
