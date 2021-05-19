describe SessionsController do
  before(:each) { request.env['HTTP_REFERER'] = 'source_page' }
  let(:success) { 
    '<?xml version="1.0" encoding="UTF-8"?>
     <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
       <cas:authenticationSuccess>
         <cas:user>web_admin</cas:user>
       </cas:authenticationSuccess>
      </cas:serviceResponse>' }
  let(:failure) {
    '<?xml version="1.0" encoding="UTF-8"?>
     <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
       <cas:authenticationFailure code=''INVALID_TICKET''>
         E_TICKET_EXPIRED
       </cas:authenticationFailure>
     </cas:serviceResponse>' }

  describe "#cas" do
    it "returns a cas URL" do
      expect(SessionsController.new.cas).to match /https.*login/
    end
  end

  describe "#new" do
    before(:each) do
      stub_request(:get, /idp-stg.login.iu.edu/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: success, headers: {})
    end
    before(:each) { get :new }
    let(:cas) { "https://idp-stg.login.iu.edu/idp/profile" }
    it "redirects to cas login" do
      expect(response).to redirect_to "#{cas}/cas/login?service=#{root_url}"
    end
  end
  describe "#validate_login" do
    context "with invalid casticket" do
      before(:each) do
        stub_request(:get, /idp-stg.login.iu.edu/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: failure, headers: {})
      end
      before(:each) { get :validate_login, ticket: casticket }
      let(:casticket) { 'foo' }
      it "assigns @casticket" do
        expect(assigns(:casticket)).to eq casticket
      end
      it "assigns @resp_user blank" do
        expect(assigns(:resp_user)).to be_blank
      end
      it "redirects to denial page" do
        expect(response).to redirect_to "#{root_url}denied.html"
      end
    end
    context "with valid casticket" do
      before(:each) do
        stub_request(:get, /idp-stg.login.iu.edu/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: success, headers: {})
      end
      before(:each) { get :validate_login, ticket: casticket }
      let(:casticket) { 'valid' }
      it "assigns @casticket" do
        expect(assigns(:casticket)).to eq casticket
      end
      it "assigns @resp_user" do
        expect(assigns(:resp_user)).not_to be_blank
      end
      it "redirects to root_url" do
        expect(response).to redirect_to root_url
      end
    end
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
    it "redirects to logout service'" do
      destroy_session
      expect(response).to redirect_to 'https://idp-stg.login.iu.edu/idp/profile/cas/logout'
    end
  end
  
end
