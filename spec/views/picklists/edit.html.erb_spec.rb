require "rails_helper"

describe "picklists/edit.html.erb" do
  let(:picklist) { FactoryGirl.create :picklist }

  it "shows a picklist" do
    assign(:picklist, picklist)
    assign(:action, 'update')
    assign(:submit_text, 'Update Picklist')
    render
    expect(rendered).to match /Picklist/
  end
end
