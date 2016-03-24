describe "root" do
  it "routes to welcome#index" do
    expect(get("/")).to route_to("welcome#index")
  end
end
