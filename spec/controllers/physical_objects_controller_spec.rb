require 'rails_helper'

describe PhysicalObjectsController do
  describe "GET index" do
    it "succeeds" do
      expect(response).to be_success
    end
  end
end
