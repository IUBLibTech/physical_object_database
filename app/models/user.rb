class User #< ActiveRecord::Base

  def self.authenticate(username)
    return false if username.nil? || username.blank?
    return true if valid_usernames.include? username
    return false
  end

  #FIXME: change to model lookup
  def self.valid_usernames
    return ["aploshay", "jaalbrec", "wgcowan",
    "pfeaster",
    "jelyon",
    "caitreyn",
    "jtshelby",
    "adbohm",
    "jearoe"
    ]
  end

  def self.current_user=(user)
    Thread.current[:current_user] = user
  end

  def self.current_user
    user_string = Thread.current[:current_user].to_s
    user_string.blank? ? "UNAVAILABLE" : user_string
  end

end
