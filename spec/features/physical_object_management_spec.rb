require "rails_helper"
require "sessions_helper"

feature "Physical Object management" do

  let(:username) { "user@example.com" }

  scenario "unauthenticated user tries to access the form for a new physical object" do
    #NOTE: the rack test server cannot visit external URLs, so a redirect to CAS rasises an error
    expect{ visit new_physical_object_path }.to raise_error(ActionController::RoutingError, /No route matches/)
  end

  scenario "signed-in user tries to create a new physical object without specifying a unit" do
    sign_in(username)

    visit new_physical_object_path
    fill_in "physical_object_title", with: "Test Title"
    click_button "Create Physical Object"

    within('#error_div'){expect(page).to have_text("Unit can't be blank")}
  end

end
