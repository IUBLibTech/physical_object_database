# Authentication method for BasicAuth
# 
# FIXME: can't seem to get before_action to work here
module BasicAuthenticationHelper

  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Settings.qc_user && password == Settings.qc_pass
    end
  end
end
