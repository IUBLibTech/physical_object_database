describe "boxes" do
  it "routes to edit" do
    expect(get("/boxes/:id/edit")).to be_routable
  end

  it "routes to add_barcode_item" do
    expect(post("/boxes/:id/add_barcode_item")).to be_routable
  end

  it "routes to unbin" do
    expect(post("/boxes/:id/unbin")).to be_routable
  end

  it "routes to index through bins" do
    expect(post("/bins/:bin_id/boxes")).to be_routable
  end

  it "routes to new through bins" do
    expect(get("/bins/:bin_id/boxes/new")).to be_routable
  end

  it "routes to create through bins" do
    expect(post("/bins/:bin_id/boxes")).to be_routable
  end
end
