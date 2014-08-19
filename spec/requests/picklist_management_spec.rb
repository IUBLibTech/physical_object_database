require 'rails_helper'
#include ControllerHelpers
#include SessionsHelper

describe "Picklist management" do
  let(:picklist) { FactoryGirl.create(:picklist) }
  before(:each) do 
    sign_in
  end
  it "renders new template" do
    get "/picklists/new"
    expect(response).to render_template :new
  end
  it "renders edit template" do
    get "/picklists/#{picklist.id}/edit"
    expect(response).to render_template :edit
  end

end
