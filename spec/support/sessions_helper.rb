#Sign-in method for testing
def sign_in(username)
  page.set_rack_session(username: username)
end

def sign_out
  page.set_rack_session(username: nil)
end
