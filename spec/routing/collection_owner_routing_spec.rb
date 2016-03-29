describe CollectionOwnerController, type: :routing do
  it "routes to #index" do
    expect(get("/collection_owner")).to route_to("collection_owner#index")
  end
  it "routes to #show" do
    expect(get("/collection_owner/:id")).to route_to("collection_owner#show", id: ':id')
  end
  it "routes to #search" do
    expect(get("/collection_owner/search")).to route_to("collection_owner#search")
  end
  it "routes to #search_results" do
    expect(post("/collection_owner/search_results")).to route_to("collection_owner#search_results")
  end
end

