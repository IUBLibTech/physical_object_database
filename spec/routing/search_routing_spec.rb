describe "search" do
  it "routes to advanced_search" do
    expect(post("/search/advanced_search")).to be_routable
  end
  it "routes to search_results" do
    expect(post("/search/search_results")).to be_routable
  end
end
