describe ConditionStatusTemplatesController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:cst) { ConditionStatusTemplate.first }
  let(:temp_cst) { FactoryGirl.create :condition_status_template }
  let(:valid_attributes) { FactoryGirl.attributes_for(:condition_status_template) }
  let(:invalid_attributes) { FactoryGirl.attributes_for(:condition_status_template, :invalid) }

  describe "GET #index" do
    before(:each) { get :index }
    it "populates @all_condition_status_templates" do
      expect(assigns(:all_condition_status_templates)["Bin"]).to be_empty
      expect(assigns(:all_condition_status_templates)["Physical Object"].size).to eq ConditionStatusTemplate.all.size
    end
    it "renders the :index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before(:each) { get :show, id: cst.id }
    it "assigns the requested object" do
      expect(assigns(:condition_status_template)).to eq cst
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before(:each) { get :new }
    it "assigns a new object" do
      expect(assigns(:condition_status_template)).to be_a_new ConditionStatusTemplate
      expect(assigns(:condition_status_template).object_type).to be_blank
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "POST #create" do
    let(:post_create) { post :create, condition_status_template: create_attributes }
    context "with valid attributes" do
      let(:create_attributes) { valid_attributes }
      after(:each) { assigns(:condition_status_template).destroy! }
      it "creates a new object" do
        expect { post_create }.to change(ConditionStatusTemplate, :count).by(1)
      end
      it "assigns the newly created object, saving" do
        post_create
        expect(assigns(:condition_status_template)).to be_a(ConditionStatusTemplate)
        expect(assigns(:condition_status_template)).to be_persisted
      end
      it "redirects to status_templates" do
        post_create
        expect(response).to redirect_to status_templates_path
      end
    end
    context "with invalid attributes" do
      let(:create_attributes) { invalid_attributes }
      it "does not create a new object" do
        expect { post_create }.not_to change(ConditionStatusTemplate, :count)
      end
      it "assigns the newly created object, without saving" do
        post_create
        expect(assigns(:condition_status_template)).to be_a(ConditionStatusTemplate)
        expect(assigns(:condition_status_template)).not_to be_persisted
      end
      it "re-renders the :new template" do
        post_create
        expect(response).to render_template :new
      end
    end
  end

  describe "GET #edit" do
    before(:each) { get :edit, id: cst.id }
    it "assigns the requested object" do
      expect(assigns(:condition_status_template)).to eq cst
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "PUT #update" do
    let(:put_update) { put :update, id: temp_cst.id, condition_status_template: update_attributes }
    let!(:original_name) { temp_cst.name }
    before(:each) { put_update }
    after(:each) { temp_cst.destroy! }
    context "with valid attributes" do
      let(:update_attributes) { { name: original_name + " updated" } }
      it "assigns the requested object" do
        expect(assigns(:condition_status_template)).to eq temp_cst
      end
      it "updates the requested object" do
        expect(temp_cst.name).to eq original_name
        temp_cst.reload
        expect(temp_cst.name).not_to eq original_name
      end
      it "redirects to status_templates" do
        expect(response).to redirect_to status_templates_path
      end
    end
    context "with invalid attributes" do
      let(:update_attributes) { { name: "" } }
      it "assigns the requested object" do
        expect(assigns(:condition_status_template)).to eq temp_cst
      end
      it "does not update the object" do
        expect(temp_cst.name).to eq original_name
        temp_cst.reload
        expect(temp_cst.name).to eq original_name
      end
      it "re-renders the :edit template" do
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE destroy" do
    let(:delete_destroy) { delete :destroy, id: temp_cst.id }
    before(:each) { temp_cst }
    it "destroys the requested object" do
      expect { delete_destroy }.to change(ConditionStatusTemplate, :count).by(-1)
    end
    it "redirects to the status_templates_path" do
      delete_destroy
      expect(response).to redirect_to status_templates_path
    end
  end

end
