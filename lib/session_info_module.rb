module SessionInfoModule
  def self.session=(session)
    #FIXME: replace with calls to session_store?
    Thread.current[:session] = session
  end
  def self.session
    Thread.current[:session]
  end
  def self.current_username
    if SessionInfoModule.session.nil? || SessionInfoModule.session[:username].nil? || SessionInfoModule.session[:username].blank?
      return "UNAVAILABLE"
    else
      return SessionInfoModule.session[:username]
    end
  end
end
