class User

  #NOTE: currently accepts any CAS user; later rewrite to look up allowed users
  def User.authenticate(username)
    return false if username.nil? || username.blank?
    return true
  end

end
