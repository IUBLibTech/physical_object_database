#mock authentication for testing in request

module RequestHelpers
  def sign_in(username = "user@example.com")
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(username)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
