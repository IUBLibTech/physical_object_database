require 'rails_helper'

describe "root" do
  it "routes to physical_objects#index" do
    expect(get("/")).to route_to("physical_objects#index")
  end
end

describe "boxes" do
  it "does not route for box/{id}/edit" do
    expect(get("/boxes/1/edit")).not_to be_routable
  end
end

describe "signin" do
  it "routes to sessions#new" do
    expect(get("/signin")).to route_to("sessions#new")
  end
end

describe "signout" do
  it "routes to sessions#destroy" do
    expect(delete("/signout")).to route_to("sessions#destroy")
  end
end

