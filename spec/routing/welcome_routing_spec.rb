describe WelcomeController, type: :routing do
  it "routes to #index" do
    expect(get("/welcome")).to route_to("welcome#index")
  end
end

