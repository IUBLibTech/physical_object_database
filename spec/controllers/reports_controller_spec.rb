require "rails_helper"
require 'debugger'

describe ReportsController do
  render_views
  before(:each) { sign_in }

  describe "GET index" do
    before(:each) { get :index }
    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
  end

end
