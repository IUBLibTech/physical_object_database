require "rails_helper"

feature "Physical Object management" do

  context "unauthenticated user" do
    before(:each) { sign_out }

    scenario "tries to access the form for a new physical object" do
      #NOTE: the rack test server cannot visit external URLs, so a redirect to CAS raises an error
      sign_in(nil)
      expect{ visit new_physical_object_path }.to raise_error(ActionController::RoutingError, /No route matches/)
    end
  end

  context "signed-in user" do  
    before(:each) { sign_in }
    scenario "tries to create a new physical object without specifying a unit" do
      visit new_physical_object_path
      fill_in "physical_object_title", with: "Test Title"
      click_button "Create Physical Object"
  
      within('#error_div'){expect(page).to have_text("Unit can't be blank")}
    end
  
    scenario "sees standard header links" do
      visit physical_objects_path
      within('#menu'){expect(page).to have_link('Physical Objects')}
      within('#menu'){expect(page).to have_link('Batches')}
      within('#menu'){expect(page).to have_link('Bins')}
      within('#menu'){expect(page).to have_link('Pick Lists')}
      within('#menu'){expect(page).to have_link('Statuses')}
      within('#menu'){expect(page).to have_link('Advanced Search')}
      within('#menu'){expect(page).to have_text('Barcode')}
      within('#basic_search_form'){expect(page).to have_field('identifier')}
    end
  end

end
