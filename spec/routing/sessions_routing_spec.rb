describe "signin" do
  it "routes to sessions#new" do
    expect(get("/signin")).to route_to("sessions#new")
  end
end

describe "signout" do
  it "routes to sessions#destroy" do
    expect(delete("/signout")).to route_to("sessions#destroy")
  end
end

describe "sessions" do
    it "routes to new" do
      expect(get("/sessions/new")).to be_routable
    end
    it "routes to destroy" do
      expect(delete("/sessions/:id")).to be_routable
    end
    it "routest to validate_login" do
      expect(get("/sessions/validate_login")).to be_routable
    end
end
