require "rails_helper"

RSpec.describe PodReportsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/pod_reports").to route_to("pod_reports#index")
    end

    it "routes to #show" do
      expect(:get => "/pod_reports/1").to route_to("pod_reports#show", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/pod_reports/1").to route_to("pod_reports#destroy", :id => "1")
    end

  end
end
