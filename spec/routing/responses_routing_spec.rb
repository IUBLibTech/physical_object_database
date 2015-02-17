describe ResponsesController do
  describe "routing" do
    it "routes to #metadata" do
      expect(:get => "/responses/metadata/1").to route_to("responses#metadata", :barcode => "1")
    end

    it "routes to #push_status" do
    	expect(:get => "/responses/push_status/json").to route_to("responses#push_status", :json => "json")
    end

  end
end
