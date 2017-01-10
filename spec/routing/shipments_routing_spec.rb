describe ShipmentsController do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/shipments").to route_to("shipments#index")
    end

    it "routes to #new" do
      expect(:get => "/shipments/new").to route_to("shipments#new")
    end

    it "routes to #new_shipment" do
      expect(:get => "/shipments/new_shipment").to route_to("shipments#new_shipment")
    end

    it "routes to #show" do
      expect(:get => "/shipments/1").to route_to("shipments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/shipments/1/edit").to route_to("shipments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/shipments").to route_to("shipments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/shipments/1").to route_to("shipments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/shipments/1").to route_to("shipments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/shipments/1").to route_to("shipments#destroy", :id => "1")
    end

    it "routes to #unload" do
      expect(:get => "/shipments/1/unload").to route_to("shipments#unload", :id => "1")
    end

    it "routes to #unload_object" do
      expect(:patch => "/shipments/1/unload_object").to route_to("shipments#unload_object", :id => "1")
    end

    it "routes to #reload" do
      expect(:get => "/shipments/1/reload").to route_to("shipments#reload", :id => "1")
    end

    it "routes to #reload_object" do
      expect(:patch => "/shipments/1/reload_object").to route_to("shipments#reload_object", :id => "1")
    end

    it "routes to #shipments_list" do
      expect(:get => "/shipments/shipments_list").to route_to("shipments#shipments_list")
    end


  end
end
