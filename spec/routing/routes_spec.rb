describe "root" do
  it "routes to physical_objects#index" do
    expect(get("/")).to route_to("physical_objects#index")
  end
end

describe "search" do
  it "routes to advanced_search" do
    expect(post("/search/advanced_search")).to be_routable
  end
  it "routes to search_results" do
    expect(post("/search/search_results")).to be_routable
  end
end

describe "status_templates" do
  it "routes to index" do
    expect(get("/status_templates")).to be_routable
  end
end


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
