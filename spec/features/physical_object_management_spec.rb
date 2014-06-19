require "rails_helper"

feature "Physical Object management" do

  scenario "Sign-in user tries to create a new physical object without specifying a unit" do
    page.set_rack_session(username: "user@example.com")

    visit "/physical_objects/new"
    fill_in "physical_object_title", with: "Test Title"
    click_button "Create Physical Object"

    within('#error_div'){expect(page).to have_text("Unit can't be blank")}
  end

end
