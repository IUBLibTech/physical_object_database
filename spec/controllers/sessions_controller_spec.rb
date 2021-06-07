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
  let(:secure_root_url) { root_url(protocol: :https) }

  describe "url helpers" do
    describe "#cas" do
      context "with no arguments" do
        it "returns a cas service root URL" do
          expect(SessionsController.new.send(:cas_url)).to match /https.*login/
        end
      end
      context "with invalid action" do
        it "returns a cas service root URL" do
          expect(SessionsController.new.send(:cas_url, :foo)).to eq SessionsController.new.send(:cas_url)
        end
      end
      context "with :logout" do
        it "returns a cas service logout URL" do
          expect(SessionsController.new.send(:cas_url, :logout)).to match /https.*login.*logout/
        end
      end
      context "with :login" do
        it "returns a cas service login URL" do
          expect(SessionsController.new.send(:cas_url, :login, service: 'foo')).to match /https.*login.*login.*foo/
        end
      end
      context "with :validate" do
        it "returns a cas service login URL" do
          expect(SessionsController.new.send(:cas_url, :validate, ticket: 'foo', service: 'bar')).to match /https.*login.*serviceValidate.*foo.*bar/
        end
      end
    end
  end

  describe "#new" do
    before(:each) do
      stub_request(:get, /idp-stg.login.iu.edu/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: success, headers: {})
    end
    before(:each) { get :new }
    it "redirects to cas login" do
      expect(response).to redirect_to SessionsController.new.send(:cas_url, :login, service: secure_root_url)
    end
  end
  describe "#validate_login" do
    context "with invalid ticket" do
      before(:each) do
        stub_request(:get, /idp.*login.iu.edu/).
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
        expect(response).to redirect_to "#{secure_root_url}denied.html"
      end
    end
    context "with invalid response" do
      before(:each) do
        stub_request(:get, /idp.*login.iu.edu/).
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
        expect(response).to redirect_to "#{secure_root_url}denied.html"
      end
    end
    context "with valid ticket" do
      before(:each) do
        stub_request(:get, /idp.*login.iu.edu/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: success, headers: {})
      end
      before(:each) { get :validate_login, ticket: cas_ticket }
      after(:each) do
        sign_out
        Thread.current[:current_username] = nil
      end
      let(:cas_ticket) { 'valid' }
      it "assigns @cas_ticket" do
        expect(assigns(:cas_ticket)).to eq cas_ticket
      end
      it "assigns @cas_user" do
        expect(assigns(:cas_user)).not_to be_blank
      end
      it "redirects to secure_root_url" do
        expect(response).to redirect_to secure_root_url
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
      expect(response).to redirect_to SessionsController.new.send(:cas_url, :logout)
    end
  end
  
end
