#mock authentication for testing in request

module RequestHelpers
  #FIXME: seed default admin user, replace
  def sign_in(username = "web_admin")
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(username)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
