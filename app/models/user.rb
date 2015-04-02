class User < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  default_scope { order(:name) }

  def self.authenticate(username)
    return false if username.nil? || username.blank?
    return true if valid_usernames.include? username
    return false
  end

  def self.valid_usernames
    return User.all.map { |user| user.username }
  end

  def self.current_user=(user)
    Thread.current[:current_user] = user
  end

  def self.current_user
    user_string = Thread.current[:current_user].to_s
    user_string.blank? ? "UNAVAILABLE" : user_string
  end

end
