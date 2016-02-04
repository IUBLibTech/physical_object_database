describe StagingPercentagesController, type: :routing do
	it "routes to index" do
		expect(get("/staging_percentages")).to route_to("staging_percentages#index")
	end
	it "routes to staging_percentage#edit" do
		expect(patch("/staging_percentages/id")).to be_routable
	end
end