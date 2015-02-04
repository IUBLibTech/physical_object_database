describe ResponsesController do
  describe "routing" do

    it "routes to #metadata" do
      expect(:get => "/responses/metadata/1").to route_to("responses#metadata", :barcode => "1")
    end

  end
end
