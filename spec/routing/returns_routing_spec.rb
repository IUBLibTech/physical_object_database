describe "returns" do
  it "routes to index" do
    expect(get("/returns")).to be_routable
  end
  it "routes to returns_bins" do
    expect(get("/returns/:id/return_bins")).to be_routable
  end
  it "routes to unload_bin" do
    expect(patch("/returns/:id/unload_bin")).to be_routable
  end
  it "routes to return_bin" do
    expect(get("/returns/:id/return_bin")).to be_routable
  end
  it "routes to physical_object_returned" do
    expect(patch("/returns/:id/physical_object_returned")).to be_routable
  end
  it "routes to bin_unpacked" do
    expect(patch("/returns/:id/bin_unpacked")).to be_routable
  end
  it "routes to batch_complete" do
    expect(patch("/returns/:id/batch_complete")).to be_routable
  end
  it "routes to return_objects" do
    expect(get("/returns/return_objects")).to route_to(controller: 'returns', action: 'return_objects')
  end
  it "routes to return_object" do
    expect(post("/returns/return_object")).to route_to(controller: 'returns', action: 'return_object')
  end

end
