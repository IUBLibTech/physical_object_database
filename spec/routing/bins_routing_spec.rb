describe "bins" do
  it "routes to add_barcode_item" do
    expect(post("/bins/:id/add_barcode_item")).to be_routable
  end

  it "routes to unbatch" do
    expect(post("/bins/:id/unbatch")).to be_routable
  end

  it "routes to seal" do
    expect(patch("/bins/:id/seal")).to be_routable
  end

  it "routes to unseal" do
    expect(patch("/bins/:id/unseal")).to be_routable
  end

  it "routes to show_boxes" do
    expect(get("/bins/:id/show_boxes")).to be_routable
  end

  it "routes to assign_boxes" do
    expect(patch("/bins/:id/assign_boxes")).to be_routable
  end

  it "routes to workflow_history" do
    expect(get("/bins/:id/workflow_history")).to be_routable
  end

end
