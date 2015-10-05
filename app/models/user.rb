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

  def self.current_user_object
    Thread.current[:current_user]
  end

  def permit?(controller, action, record)
    permissions.map { |p| p[controller][action] }.any?
  end

  def permissions
    roles.map { |r| ROLE_PERMISSIONS[r] }
  end

  def roles
    [:all_access]
  end

  ROLES = [:nil_access, :all_access, :qc_access]
  NIL_ACCESS = Hash.new({})
  ALL_ACCESS = Hash.new(Hash.new(true))
  ROLE_PERMISSIONS = {
    nil_access: NIL_ACCESS,
    all_access: ALL_ACCESS,
    qc_access: NIL_ACCESS.merge({
      QualityControlController => Hash.new(true)
    })
  }
end
