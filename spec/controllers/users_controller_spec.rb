# Users is table with seed data, protected from automated test cleanup
# Manual record deletion is necessary for each test, where applicable
#
describe UsersController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
  
  let(:user) { FactoryBot.create(:user) }
  let(:valid_user) { FactoryBot.build(:user) }
  let(:invalid_user) { FactoryBot.build(:user, :invalid) }

  let(:valid_attributes) { FactoryBot.attributes_for(:user) }
  let(:invalid_attributes) { FactoryBot.attributes_for(:user, :invalid) }

  describe "GET #index" do
    before(:each) do
      user
      get :index
    end
    after(:each) { user.destroy }
    it "assigns all users as @users" do
      expect(assigns(:users)).to include user 
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    before(:each) { get :show, id: user.id }
    after(:each) { user.destroy }
    it "assigns the requested user as @user" do
      expect(assigns(:user)).to eq(user)
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    before(:each) { get :new }
    it "assigns a new user as @user" do
      expect(assigns(:user)).to be_a_new(User)
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    before(:each) { get :edit, id: user.id }
    after(:each) { user.destroy }
    it "assigns the requested user as @user" do
      expect(assigns(:user)).to eq(user)
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    let(:post_create) { post :create, user: create_attributes }
    context "with valid params" do
      let(:create_attributes) { valid_attributes }
      after(:each) { assigns(:user).destroy }
      it "creates a new User" do
        expect { post_create }.to change(User, :count).by(1)
      end
      it "assigns a newly created user as @user" do
        post_create
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end
      it "redirects to the created user" do
        post_create
        expect(response).to redirect_to(assigns(:user))
      end
    end
    context "with invalid params" do
      let(:create_attributes) { invalid_attributes }
      it "assigns a newly created but unsaved user as @user" do
        post_create
        expect(assigns(:user)).to be_a_new(User)
        expect(assigns(:user)).not_to be_persisted
      end
      it "re-renders the 'new' template" do
        post_create
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:put_update) { put :update, id: user.id, user: update_attributes }
    before(:each) { put_update }
    after(:each) { user.destroy }
    context "with valid params" do
      let(:original_name) { user.name }
      let(:update_attributes) { { name: original_name + " updated" } }
      it "assigns the requested user as @user" do
        expect(assigns(:user)).to eq(user)
      end
      it "updates the requested user" do
        expect(user.name).to eq original_name
        user.reload
        expect(user.name).not_to eq original_name
      end
      it "redirects to the user" do
        expect(response).to redirect_to(user)
      end
    end
    context "with invalid params" do
      let(:update_attributes) { { name: "" } }
      it "assigns the user as @user" do
        expect(assigns(:user)).to eq(user)
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
    context "setting a role" do
      let(:update_attributes) { {name: user.name, smart_team_user: true} }
      it "sets as smart team user" do
        expect(user.smart_team_user?).to eq false
	user.reload
        expect(user.smart_team_user?).to eq true
      end
    end
  end

  describe "DELETE #destroy" do
    let(:delete_destroy) { delete :destroy, id: user.id }
    before(:each) { user }
    it "destroys the requested user" do
      expect { delete_destroy }.to change(User, :count).by(-1)
    end
    it "redirects to the users list" do
      delete_destroy
      expect(response).to redirect_to(users_path)
    end
  end

end
