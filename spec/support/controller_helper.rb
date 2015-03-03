# mock authentication for testing in controllers

module ControllerHelpers
  def sign_in(username = "user@example.com" )
    allow(controller).to receive(:current_user).and_return(username)
  end
  def sign_out
    sign_in(nil)
  end
  def basic_auth
    user = Settings.qc_user
    password = Settings.qc_pass
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,password)
  end
  def invalid_auth
    user = 'invalid_username'
    password = 'invalid_password'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,password)
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
end
