describe "group keys" do
  it "routes to index" do
    expect(get "/group_keys").to route_to action: "index", controller: "group_keys"
  end
  it "routes to show" do
    expect(get "/group_keys/:id").to route_to action: "show", controller: "group_keys", id: ":id"
  end
  it "routes to new" do
    expect(get "/group_keys/new").to route_to action: "new", controller: "group_keys"
  end
  it "routes to edit" do
    expect(get("/group_keys/:id/edit")).to be_routable
  end
  it "routes to create" do
    expect(post("/group_keys")).to route_to action: "create", controller: "group_keys"
  end
  it "routes to update" do
    expect(patch("/group_keys/:id")).to route_to action: "update", controller: "group_keys", id: ":id"
  end
  it "routes to destroy" do
    expect(delete("/group_keys/:id")).to route_to action: "destroy", controller: "group_keys", id: ":id"
  end
  it "routes to reorder" do
    expect(patch("/group_keys/:id/reorder")).to route_to action: "reorder", controller: "group_keys", id: ":id"
  end
  it "routes to include" do
    expect(patch("/group_keys/:id/include")).to route_to action: "include", controller: "group_keys", id: ":id"
  end

  it "routes to physical_object new through group_keys" do
    expect(get("/group_keys/:group_key_id/physical_objects/new")).to be_routable
  end
end

