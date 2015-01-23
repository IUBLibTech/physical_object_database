#authentication methods for testing in models

module ModelHelpers
  def sign_in(username = "user@example.com")
    User.current_user = username
  end
  
  def sign_out
    sign_in(nil)
  end
end

RSpec.configure do |config|
  config.include ModelHelpers, type: :model
end
