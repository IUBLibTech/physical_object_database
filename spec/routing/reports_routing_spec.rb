describe ReportsController do
  describe "reports" do
    it "routes to #index" do
      expect(get: "/reports").to route_to("reports#index")
    end
  end
end
