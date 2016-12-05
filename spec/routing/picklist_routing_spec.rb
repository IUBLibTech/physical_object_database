describe "picklists" do
  it "does not route to index" do
    expect(get("/picklists")).not_to be_routable
  end
  it "routes to patch pack_list on collection" do
    expect(patch("/picklists/pack_list")).to be_routable
  end
  it "routes to get pack_list on collection" do
    expect(get("/picklists/pack_list")).to be_routable
  end
  it "routes to patch pack_list on member" do
    expect(patch("/picklists/1/pack_list")).to be_routable
  end
  it "routes to get pack_list on member" do
    expect(get("/picklists/1/pack_list")).to be_routable
  end
  it "routes to assign_to_container" do
    expect(patch("/picklists/assign_to_container")).to be_routable
  end
  it "routes to remove_from_container" do
    expect(patch("/picklists/remove_from_container")).to be_routable
  end
  it "routes to resend" do
    expect(patch('/picklists/1/resend')).to be_routable
  end
end
