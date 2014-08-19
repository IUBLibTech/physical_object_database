require "rails_helper"

describe "picklists/new.html.erb" do
  it "shows a new picklist" do
    assign(:picklist, Picklist.new)
    assign(:edit_mode, true)
    assign(:action, 'create')
    assign(:submit_text, 'Create Picklist')
    render
    expect(rendered).to match /Picklist/
  end
end
