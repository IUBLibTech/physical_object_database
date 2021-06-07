module SessionsHelper

  def sign_in(username)
    self.current_username = username
  end

  def current_username=(username)
    session[:username] = username
  end

  def current_username
    session[:username]
  end

  def current_username?(username)
    session[:username] == username
  end

  # provided for compatibility with pundit
  def current_user
    session[:username]
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url(ticket: params[:ticket])
    end
  end

  def signed_in?
    !current_username.nil?
  end

  def sign_out
    self.current_username = nil
  end

  def store_location
    return if session[:return_to].present?
    session[:return_to] = request.url if request.get?
  end
  
  def redirect_back_or_to(default = secure_root_url)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def secure_root_url
    root_url(protocol: :https)
  end
end
