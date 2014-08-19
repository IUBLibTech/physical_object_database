#authentication methods for testing in Capybara

module FeatureHelpers
  def sign_in(username = "user@example.com")
    page.set_rack_session(username: username)
    SessionInfoModule.session = page.get_rack_session
  end
  
  def sign_out
    sign_in(nil)
  end
end

RSpec.configure do |config|
  #config.include FeatureHelpers, type: :feature
end
