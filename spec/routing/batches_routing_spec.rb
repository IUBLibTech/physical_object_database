describe "batches" do
  it "routes to workflow_history" do
    expect(get("/batches/:id/workflow_history")).to be_routable
  end
  it "routes to add_bin" do
    expect(patch("/batches/id/add_bin")).to be_routable
  end
  it "routes to remove_bin" do
    expect(post("/batches/id/remove_bin")).to be_routable
  end
end
