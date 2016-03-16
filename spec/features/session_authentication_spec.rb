feature "Session authentication" do 

  context "unauthenticated user" do
    before(:each) { sign_out }
    scenario "cannot access the site root" do
      #NOTE: the rack test server cannot visit external URLs, so a redirect to CAS raises an error
      sign_in(nil)
      expect{ visit root_path }.to raise_error(ActionController::RoutingError, /No route matches/)
    end
  end

  context "signed-in user" do  
    before(:each) { sign_in }
    scenario "can access the site root" do
      expect{ visit root_path }.not_to raise_error
    end
  end

end
