describe WorkflowStatusTemplatesController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:wst) { WorkflowStatusTemplate.first }
  let(:temp_wst) { FactoryBot.create :workflow_status_template }
  let(:valid_attributes) { FactoryBot.attributes_for(:workflow_status_template) }
  let(:invalid_attributes) { FactoryBot.attributes_for(:workflow_status_template, :invalid) }

  describe "GET #show" do
    before(:each) { get :show, id: wst.id }
    it "assigns the requested object" do
      expect(assigns(:workflow_status_template)).to eq wst
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before(:each) { get :new }
    it "assigns a new object" do
      expect(assigns(:workflow_status_template)).to be_a_new WorkflowStatusTemplate
      expect(assigns(:workflow_status_template).object_type).to be_blank
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "POST #create" do
    let(:post_create) { post :create, workflow_status_template: create_attributes }
    context "with valid attributes" do
      let(:create_attributes) { valid_attributes }
      after(:each) { assigns(:workflow_status_template).destroy! }
      it "creates a new object" do
        expect { post_create }.to change(WorkflowStatusTemplate, :count).by(1)
      end
      it "assigns the newly created object, saving" do
        post_create
        expect(assigns(:workflow_status_template)).to be_a(WorkflowStatusTemplate)
        expect(assigns(:workflow_status_template)).to be_persisted
      end
      it "redirects to status_templates" do
        post_create
        expect(response).to redirect_to status_templates_path
      end
    end
    context "with invalid attributes" do
      let(:create_attributes) { invalid_attributes }
      it "does not create a new object" do
        expect { post_create }.not_to change(WorkflowStatusTemplate, :count)
      end
      it "assigns the newly created object, without saving" do
        post_create
        expect(assigns(:workflow_status_template)).to be_a(WorkflowStatusTemplate)
        expect(assigns(:workflow_status_template)).not_to be_persisted
      end
      it "re-renders the :new template" do
        post_create
        expect(response).to render_template :new
      end
    end
  end

  describe "GET #edit" do
    before(:each) { get :edit, id: wst.id }
    it "assigns the requested object" do
      expect(assigns(:workflow_status_template)).to eq wst
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "PUT #update" do
    let(:put_update) { put :update, id: temp_wst.id, workflow_status_template: update_attributes }
    let!(:original_name) { temp_wst.name }
    before(:each) { put_update }
    after(:each) { temp_wst.destroy! }
    context "with valid attributes" do
      let(:update_attributes) { { name: original_name + " updated" } }
      it "assigns the requested object" do
        expect(assigns(:workflow_status_template)).to eq temp_wst
      end
      it "updates the requested object" do
        expect(temp_wst.name).to eq original_name
        temp_wst.reload
        expect(temp_wst.name).not_to eq original_name
      end
      it "redirects to status_templates" do
        expect(response).to redirect_to status_templates_path
      end
    end
    context "with invalid attributes" do
      let(:update_attributes) { { name: "" } }
      it "assigns the requested object" do
        expect(assigns(:workflow_status_template)).to eq temp_wst
      end
      it "does not update the object" do
        expect(temp_wst.name).to eq original_name
        temp_wst.reload
        expect(temp_wst.name).to eq original_name
      end
      it "re-renders the :edit template" do
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE destroy" do
#case: cascading decrement of following items
    let(:delete_destroy) { delete :destroy, id: temp_wst.id }
    before(:each) { temp_wst }
    it "destroys the requested object" do
      expect { delete_destroy }.to change(WorkflowStatusTemplate, :count).by(-1)
    end
    it "redirects to the status_templates_path" do
      delete_destroy
      expect(response).to redirect_to status_templates_path
    end
  end

#privates: insert_sequence, move_sequence
end
