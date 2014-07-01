module SessionsHelper
  include SessionInfoModule

  def sign_in(username)
    self.current_user = username
  end

  def current_user=(username)
    session[:username] = username
    SessionInfoModule.session = session
  end

  def current_user
    session[:username]
  end

  def current_user?(username)
    session[:username] == username
  end

  def signed_in_user
    puts "signed_in_user: current user: #{current_user}"
    unless signed_in?
      store_location
      redirect_to signin_url
    end
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    self.current_user = nil
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end
  
  def redirect_back_or_to(default=root_url)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end
end
