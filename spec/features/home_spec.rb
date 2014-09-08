require 'rails_helper'

feature 'Home' do
  it 'should not have JavaScript errors', :js => true do
    visit(root_path)
    expect(page).not_to have_errors
  end
end
