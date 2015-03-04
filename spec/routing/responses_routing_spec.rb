describe ResponsesController do
  describe "routing" do
    it "routes to #metadata" do
      expect(get: "/responses/objects/1/metadata").to route_to("responses#metadata", mdpi_barcode: "1")
    end

    it "routes to #notify" do
      expect(post: "/responses/notify/").to route_to("responses#notify")
    end

    it "routes to #push_status" do
      expect(post: "/responses/objects/1/state").to route_to("responses#push_status", mdpi_barcode: "1")
    end

    it "routes to #pull_state" do
    	expect(get: "/responses/objects/1/state").to route_to("responses#pull_state", mdpi_barcode: "1")
    end

    it "routes to #flags" do
    	expect(get: "/responses/objects/1/flags").to route_to("responses#flags", mdpi_barcode: "1")
    end

    it "routes to #transfer_request" do
    	expect(post: "/responses/transfers").to route_to("responses#transfer_request")
    end

    it "routes to #transfers_index" do
    	expect(get: "/responses/transfers").to route_to("responses#transfers_index")
    end

    it "routes to #transfer_result" do
    	expect(post: "/responses/transfers/1").to route_to("responses#transfer_result", mdpi_barcode: "1")
    end

  end
end
