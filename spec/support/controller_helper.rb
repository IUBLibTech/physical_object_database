# mock authentication for testing in controllers

module ControllerHelpers
  def sign_in(username = "user@example.com" )
    allow(controller).to receive(:current_user).and_return(username)
  end
  def sign_out
    sign_in(nil)
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
end
