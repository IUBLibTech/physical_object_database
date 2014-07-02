#Sign-in method for testing
def sign_in(username)
  page.set_rack_session(username: username)
  SessionInfoModule.session = page.get_rack_session
end

def sign_out
  page.set_rack_session(username: nil)
  SessionInfoModule.session = page.get_rack_session
  #FIXME: test whether above line works...
end
