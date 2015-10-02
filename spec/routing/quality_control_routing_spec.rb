describe QualityControlController, type: :routing do
  it "routes to QC index" do
    expect(get("/quality_control/")).to route_to("quality_control#index")
  end
  it "routes to QC#decide" do
    expect(patch("/quality_control/decide/:id")).to route_to("quality_control#decide", id: ':id')
  end
  it "routes to #auto_accept" do
    expect(get("/quality_control/auto_accept")).to route_to("quality_control#auto_accept")
  end
end

