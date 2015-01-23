class User

  #NOTE: currently accepts any CAS user; later rewrite to look up allowed users
  def self.authenticate(username)
    return false if username.nil? || username.blank?
    return true
  end

  def self.current_user=(user)
    Thread.current[:current_user] = user
  end

  def self.current_user
    user_string = Thread.current[:current_user].to_s
    user_string.blank? ? "UNAVAILABLE" : user_string
  end

end
