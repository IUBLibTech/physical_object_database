module SessionInfoModule
  def self.session=(session)
    #FIXME: replace with calls to session_store?
    Thread.current[:session] = session
  end
  def self.session
    Thread.current[:session]
  end
end
