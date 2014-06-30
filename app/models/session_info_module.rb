module SessionInfoModule
  def self.session=(session)
    Thread.current[:session] = session
  end
  def self.session
    Thread.current[:session]
  end
  def self.test
    "foo"
  end
end
