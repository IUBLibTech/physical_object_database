describe MessagesController, :type => :controller do
  render_views
  before(:each) { sign_in }

  let!(:message) { FactoryGirl.create :message }

  describe "GET index" do
    before(:each) { get :index }
    it "assigns all messages as @messages" do
      expect(assigns(:messages)).to eq([message])
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: message.id }
    it "assigns the requested message as @message" do
      expect(assigns(:message)).to eq(message)
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET new" do
    before(:each) { get :new }
    it "assigns a new message as @message" do
      expect(assigns(:message)).to be_a_new(Message)
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: message.id }
    it "assigns the requested message as @message" do
      expect(assigns(:message)).to eq(message)
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST create" do
    shared_examples "POST create examples" do |request_format|
      describe "with valid params" do
        let(:post_params) { FactoryGirl.attributes_for :message }
        it "creates a new Message" do
          expect { post_create }.to change(Message, :count).by(1)
        end
        it "assigns a newly created message as @message" do
          post_create
          expect(assigns(:message)).to be_a(Message)
          expect(assigns(:message)).to be_persisted
        end
	if request_format == :http
          it "redirects to the created message" do
            post_create
            expect(response).to redirect_to(Message.last)
          end
	elsif request_format == :json
	  it "responds with success" do
	    post_create
	    expect(response).to be_success
	  end
	end
      end
      describe "with invalid params" do
        let(:post_params) { FactoryGirl.attributes_for :message, :invalid }
        it "does not create a new message" do
          expect { post_create }.not_to change(Message, :count)
        end
        it "assigns a newly created but unsaved message as @message" do
          post_create
          expect(assigns(:message)).to be_a_new(Message)
        end
	if request_format == :http
          it "re-renders the 'new' template" do
            post_create
            expect(response).to render_template("new")
          end
	elsif request_format == :json
	  it "responds with failure" do
	    post_create
	    expect(response).not_to be_success
	  end
	end
      end
    end
    context "over JSON" do
      let(:post_create) { post :create, { message: post_params }.merge({ format: :json }) }
      include_examples "POST create examples", :json
    end
    context "over HTTP" do
      let(:post_create) { post :create, message: post_params }
      include_examples "POST create examples", :http
    end
  end

  describe "PUT update" do
    before(:each) { put :update, id: message.id, message: put_params }
    describe "with valid params" do
      let(:put_params) { { content: "Updated " + message.content } }
      it "updates the requested message" do
        expect(message.content).not_to match /^Updated/
        message.reload
        expect(message.content).to match /^Updated/
      end
      it "assigns the requested message as @message" do
        expect(assigns(:message)).to eq(message)
      end
      it "redirects to the message" do
        expect(response).to redirect_to(message)
      end
    end
    describe "with invalid params" do
      let(:put_params) { { content: nil } }
      it "assigns the message as @message" do
        expect(assigns(:message)).to eq(message)
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    let(:delete_destroy) { delete :destroy, id: message.id }
    it "destroys the requested message" do
      expect { delete_destroy }.to change(Message, :count).by(-1)
    end
    it "redirects to the messages list" do
      delete_destroy
      expect(response).to redirect_to(messages_url)
    end
  end

end
