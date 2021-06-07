describe SessionsHelper do
  let(:username) { 'foo' }
  describe "#sign_in(username)" do
    it "assigns current_username" do
      helper.sign_in(username)
      expect(helper.current_username).to eq username
    end
  end
  describe "#current_username=(username)" do
    it "saves username to session" do
      expect(session[:username]).to be_nil
      helper.current_username = username
      expect(session[:username]).to eq username
    end
  end
  describe "#current_username" do
    it "returns session[:username]" do
      expect(helper.current_username).to be_nil
      session[:username] = username
      expect(helper.current_username).to eq username
    end
  end
  describe "#current_username?(username)" do
    context "when session[:username] matches" do
      before(:each) { session[:username] = username }
      it "returns true" do
        expect(helper.current_username?(username)).to eq true
      end
    end
    context "when session[:username] does not matche" do
      before(:each) { session[:username] = "a differnet #{username}" }
      it "returns false" do
        expect(helper.current_username?(username)).to eq false
      end
    end
  end
  describe "#current_user" do
    it "returns session[:username]" do
      expect(helper.current_user).to be_nil
      session[:username] = username
      expect(helper.current_user).to eq username
    end
  end
  describe "#signed_in_user" do
    context "when already signed in" do
      before(:each) { helper.sign_in(username) }
      it "does nothing" do
        expect(helper.signed_in_user).to be_nil
      end
    end
    context "when not signed in" do
      skip "cannot directly test redirect_to in helper test"
    end
  end
  describe "#signed_in?" do
    it "returns false until user has signed in" do
      expect(helper.signed_in?).to eq false
    end
  end
  describe "#sign_out" do
    it "assigns current_username to nil" do
      helper.current_username = username
      expect(helper.current_username).not_to be_nil
      helper.sign_out
      expect(helper.current_username).to be_nil
    end
  end
  describe "#store_location" do
    it "stashes location in session[:return_to]" do
      helper.store_location
      expect(session[:return_to]).to eq 'http://test.host'
    end
  end
  describe "#redirect_back_or_to(default = secure_root_url)" do
    context "with a session[:return_to]" do
      before(:each) { session[:return_to] = 'http://test.host' }
      skip "cannot directly test redirect_to in helper test"
    end
    context "without a session[:return_to]" do
      context "passing a default argument" do
        skip "cannot directly test redirect_to in helper test"
      end
      context "without passing a default argument" do
        skip "cannot directly test redirect_to in helper test"
      end
    end
  end
end
