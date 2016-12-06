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
  it "routes to list_bins" do
    expect(get("/batches/:id/list_bins")).to route_to(controller: 'batches', id: ':id', action: 'list_bins')
  end
  it "routes to archived_to_picklist" do
    expect(patch("/batches/:id/archived_to_picklist")).to route_to(controller: 'batches', id: ':id', action: 'archived_to_picklist')
  end
end
