#authentication methods for testing in Capybara

module FeatureHelpers
  def sign_in(username = "user@example.com")
    page.set_rack_session(username: username)
    User.current_user = username
  end
  
  def sign_out
    sign_in(nil)
  end

  def confirm_popup
    page.driver.browser.accept_js_confirms
  end

  def reject_popup
    page.driver.browser.reject_js_confirms
  end

  def conclude_jquery
    Timeout.timeout(Capybara.default_wait_time) do
      loop until page.evaluate_script('jQuery.active').zero?
    end
  end

end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
