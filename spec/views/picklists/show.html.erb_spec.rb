require "rails_helper"

describe "picklists/show.html.erb" do
  let(:picklist) { FactoryGirl.create :picklist }

  it "shows a picklist" do
    assign(:picklist, picklist)
    assign(:edit_mode, false)
    render
    expect(rendered).to match /Picklist/
  end
end
