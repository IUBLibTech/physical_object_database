describe "digital_provenance" do
  it "routes to show" do
    expect(get("/digital_provenance/:id")).to route_to("digital_provenance#show", id: ":id")
  end
  it "routes to edit" do
    expect(get("/digital_provenance/:id/edit")).to route_to("digital_provenance#edit", id: ":id")
  end
  it "routes to update" do
    expect(patch("/digital_provenance/:id")).to route_to("digital_provenance#update", id: ":id")
  end
end
