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

  describe "url helpers" do
    describe "#cas" do
      it "returns a cas service root URL" do
        expect(SessionsController.new.cas).to match /https.*login/
      end
    end
  
    describe "#ticket_url" do
      it "returns a service URL to request a ticket" do
        expect(SessionsController.new.ticket_url('')).to match /login.*service/
      end
    end
  
    describe "#validation_url" do
      it "returns a service URL to validate a specific ticket" do
        expect(SessionsController.new.validation_url('', '')).to match /login.*validate.*ticket/i
      end
    end

    describe "#logout_url" do
      it "returns a service URL to log out of CAS" do
        expect(SessionsController.new.logout_url).to match /login.*logout/i
      end
    end
  end

  describe "#new" do
    before(:each) do
      stub_request(:get, /idp.login.iu.edu/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: success, headers: {})
    end
    before(:each) { get :new }
    it "redirects to cas login" do
      expect(response).to redirect_to SessionsController.new.ticket_url(root_url)
    end
  end
  describe "#validate_login" do
    context "with invalid ticket" do
      before(:each) do
        stub_request(:get, /idp.login.iu.edu/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: failure, headers: {})
      end
      before(:each) { get :validate_login, ticket: cas_ticket }
      let(:cas_ticket) { 'foo' }
      it "assigns @cas_ticket" do
        expect(assigns(:cas_ticket)).to eq cas_ticket
      end
      it "assigns @cas_user blank" do
        expect(assigns(:cas_user)).to be_blank
      end
      it "redirects to denial page" do
        expect(response).to redirect_to "#{root_url}denied.html"
      end
    end
    context "with invalid response" do
      before(:each) do
        stub_request(:get, /idp.login.iu.edu/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: 'non-parsing response', headers: {})
      end
      before(:each) { get :validate_login, ticket: cas_ticket }
      let(:cas_ticket) { 'foo' }
      it "assigns @cas_ticket" do
        expect(assigns(:cas_ticket)).to eq cas_ticket
      end
      it "assigns @cas_user blank" do
        expect(assigns(:cas_user)).to be_blank
      end
      it "redirects to denial page" do
        expect(response).to redirect_to "#{root_url}denied.html"
      end
    end
    context "with valid ticket" do
      before(:each) do
        stub_request(:get, /idp.login.iu.edu/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: success, headers: {})
      end
      before(:each) { get :validate_login, ticket: cas_ticket }
      let(:cas_ticket) { 'valid' }
      it "assigns @cas_ticket" do
        expect(assigns(:cas_ticket)).to eq cas_ticket
      end
      it "assigns @cas_user" do
        expect(assigns(:cas_user)).not_to be_blank
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
      expect(response).to redirect_to SessionsController.new.logout_url
    end
  end
  
end
