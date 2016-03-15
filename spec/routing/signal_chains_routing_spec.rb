RSpec.describe SignalChainsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/signal_chains").to route_to("signal_chains#index")
    end

    it "routes to #new" do
      expect(:get => "/signal_chains/new").to route_to("signal_chains#new")
    end

    it "routes to #show" do
      expect(:get => "/signal_chains/1").to route_to("signal_chains#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/signal_chains/1/edit").to route_to("signal_chains#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/signal_chains").to route_to("signal_chains#create")
    end

    it "routes to #update" do
      expect(:put => "/signal_chains/1").to route_to("signal_chains#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/signal_chains/1").to route_to("signal_chains#destroy", :id => "1")
    end

    it "routes to #include" do
      expect(:patch => "/signal_chains/1/include").to route_to("signal_chains#include", id: "1")
    end

    it "routes to #reorder" do
      expect(:patch => "/signal_chains/1/reorder").to route_to("signal_chains#reorder", id: "1")
    end

  end
end
