describe MachinesController do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/machines").to route_to("machines#index")
    end

    it "routes to #new" do
      expect(:get => "/machines/new").to route_to("machines#new")
    end

    it "routes to #show" do
      expect(:get => "/machines/1").to route_to("machines#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/machines/1/edit").to route_to("machines#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/machines").to route_to("machines#create")
    end

    it "routes to #update" do
      expect(:put => "/machines/1").to route_to("machines#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/machines/1").to route_to("machines#destroy", :id => "1")
    end

  end
end
