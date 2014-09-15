require "rails_helper"

RSpec.describe SpreadsheetsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/spreadsheets").to route_to("spreadsheets#index")
    end

    #new is disabled, but is interpreted as an id
    it "does NOT route to #new" do
      expect(:get => "/spreadsheets/new").to route_to("spreadsheets#show", id: "new")
    end

    it "routes to #show" do
      expect(:get => "/spreadsheets/1").to route_to("spreadsheets#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/spreadsheets/1/edit").to route_to("spreadsheets#edit", :id => "1")
    end

    #create is disabled
    it "does NOT route to #create" do
      expect(:post => "/spreadsheets").not_to be_routable
    end

    it "routes to #update" do
      expect(:put => "/spreadsheets/1").to route_to("spreadsheets#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/spreadsheets/1").to route_to("spreadsheets#destroy", :id => "1")
    end

  end
end
