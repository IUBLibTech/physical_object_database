feature 'Home' do
  before(:each) { sign_in }

  it 'should not have JavaScript errors', :js => true do
    visit(root_path)
  end
end
