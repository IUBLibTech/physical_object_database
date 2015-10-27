# mock authentication for testing in controllers

module ControllerHelpers
  #FIXME: add admin user to seed data, use here
  def sign_in(username = "web_admin")
    allow(controller).to receive(:current_username).and_return(username)
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
