describe "status_templates" do
  it "routes to index" do
    expect(get("/status_templates")).to be_routable
  end
end
