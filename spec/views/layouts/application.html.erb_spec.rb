require "rails_helper"

describe "layouts/application" do

  it "displays an environment notice" do
    render

    expect(rendered).to match /Environment/
  end

end
