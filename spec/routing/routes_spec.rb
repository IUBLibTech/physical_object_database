require 'rails_helper'

describe "root" do
  it "routes to physical_objects#index" do
    expect(get("/")).to route_to("physical_objects#index")
  end
end
