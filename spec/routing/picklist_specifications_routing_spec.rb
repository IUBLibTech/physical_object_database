describe "picklist_specifications" do
  it "routes to tm_form" do
    expect(get("/picklist_specifications/tm_form")).to be_routable
  end
  it "routes to query" do
    expect(get("/picklist_specifications/:id/query")).to be_routable
  end
  it "routes to picklist_list" do
    expect(get("/picklist_specifications/picklist_list")).to be_routable 
  end
  it "routes to new_picklist" do
    expect(get("/picklist_specifications/new_picklist")).to be_routable
  end
  it "routes to query_add" do
    expect(patch("/picklist_specifications/:id/query_add")).to be_routable
  end
  it "routes to update" do
    expect(post("/picklist_specifications/:id")).to be_routable
  end
end 
