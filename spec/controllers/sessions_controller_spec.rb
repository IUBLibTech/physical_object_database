describe SessionsController do
  before(:each) { request.env['HTTP_REFERER'] = 'source_page' }

  describe "#cas_reg" do
    it "returns a cas-reg URL" do
      expect(SessionsController.new.cas_reg).to match /https.*cas-reg/
    end
  end

  describe "#cas" do
    it "returns a cas URL" do
      expect(SessionsController.new.cas_reg).to match /https.*cas/
    end
  end

  describe "#new" do
    before(:each) { get :new }
    let(:cas) { "https://cas.iu.edu" }
    it "redirects to cas login" do
      expect(response).to redirect_to "#{cas}/cas/login?cassvc=ANY&casurl=#{root_url}sessions/validate_login"
    end
  end
  describe "#validate_login" do
    before(:each) { get :validate_login, casticket: casticket }
    context "with invalid casticket" do
      let(:casticket) { 'foo' }
      it "assigns @casticket" do
        expect(assigns(:casticket)).to eq casticket
      end
      it "assigns @resp=no" do
        expect(assigns(:resp)).to match /^no/
      end
      it "redirects to denial page" do
        expect(response).to redirect_to "#{root_url}denied.html"
      end
    end
    #FIXME: test valid casticket, somehow?
  end
  describe "#destroy" do
    let(:destroy_session) { delete :destroy }
    after(:each) { session[:username] = nil }
    it "signs out user" do
      session[:username] = 'some value'
      expect(session[:username]).not_to be_nil
      destroy_session
      expect(session[:username]).to be_nil
    end
    it "redirects to 'https://cas.iu.edu/cas/logout'" do
      destroy_session
      expect(response).to redirect_to 'https://cas.iu.edu/cas/logout'
    end
  end
  
end
