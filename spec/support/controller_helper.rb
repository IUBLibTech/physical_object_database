#mock authentication for testing in controllers

module ControllerHelpers
  def sign_in(user = double('user'))
    allow(controller).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, :type => :controller
end
